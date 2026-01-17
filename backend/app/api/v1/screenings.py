from fastapi import APIRouter, UploadFile, File, Depends
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from pathlib import Path
import uuid
import shutil
import os

import cloudinary
import cloudinary.uploader

from app.core.database import get_db
from app.core.config import settings
from app.api.deps import get_current_user
from app.models.screening import Screening
from app.models.referral import Referral
from app.services.explanation_service import cataract_decision
from app.services.referral_service import create_referral_data
from app.services.ml_client import predict_image


router = APIRouter(prefix="/screenings", tags=["Screenings"])


# ================= CLOUDINARY CONFIG =================
cloudinary.config(
    cloud_name=settings.CLOUDINARY_CLOUD_NAME,
    api_key=settings.CLOUDINARY_API_KEY,
    api_secret=settings.CLOUDINARY_API_SECRET,
)


# ================= TEMP DIRECTORY (ML ONLY) =================
BASE_DIR = Path(__file__).resolve().parent.parent
UPLOAD_DIR = BASE_DIR / "uploads"
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


@router.post("/")
def create_screening(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    # ================= 1️⃣ SAVE TEMP FILE =================
    file_id = f"{uuid.uuid4()}.jpg"
    file_path = UPLOAD_DIR / file_id

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    try:
        # ================= 2️⃣ RUN ML MODEL =================
        probs = predict_image(str(file_path))

        # ================= 3️⃣ DECISION =================
        decision = cataract_decision(probs["prob_cataract"])

        # ================= 4️⃣ UPLOAD TO CLOUDINARY =================
        upload_result = cloudinary.uploader.upload(
            str(file_path),
            folder="visioncare/screenings",
            resource_type="image",
        )

        image_url = upload_result["secure_url"]

    finally:
        # ================= 5️⃣ CLEAN TEMP FILE =================
        if file_path.exists():
            os.remove(file_path)

    # ================= 6️⃣ SAVE SCREENING =================
    screening = Screening(
        patient_id=user.id,
        image_url=image_url,  # ✅ CLOUDINARY URL
        prob_normal=probs["prob_normal"],
        prob_cataract=probs["prob_cataract"],
        result=decision["result"],
        confidence_score=decision["confidence_score"],
        confidence_level=decision["confidence_level"],
        explanation={"message": decision["message"]},
    )

    if screening.confidence_level.upper() in ["MEDIUM", "HIGH"]:
        screening.next_followup_due = datetime.utcnow() + timedelta(days=30)

    db.add(screening)
    db.commit()
    db.refresh(screening)

    # ================= 7️⃣ REFERRAL =================
    referral_data = create_referral_data(screening.confidence_level)

    if referral_data:
        referral = Referral(
            screening_id=screening.id,
            specialty=referral_data["specialty"],
            urgency=referral_data["urgency"],
            reason=referral_data["reason"],
        )
        db.add(referral)
        db.commit()

    # ================= 8️⃣ RESPONSE =================
    response = {
        "screening_id": screening.id,
        "image_url": image_url,
        "prob_normal": screening.prob_normal,
        "prob_cataract": screening.prob_cataract,
        "decision": {
            "result": screening.result,
            "confidence_level": screening.confidence_level,
            "confidence_score": screening.confidence_score,
            "message": screening.explanation["message"],
        },
    }

    if referral_data:
        response["referral"] = {
            "specialty": referral_data["specialty"],
            "urgency": referral_data["urgency"],
        }

    return response


@router.get("/my")
def get_my_screenings(
    db: Session = Depends(get_db),
    user = Depends(get_current_user),
):
    screenings = (
        db.query(Screening)
        .filter(Screening.patient_id == user.id)
        .order_by(Screening.created_at.desc())
        .all()
    )
    
    return [
        {
            "screening_id": s.id,
            "created_at": s.created_at,
            "prob_normal": s.prob_normal,
            "prob_cataract": s.prob_cataract,
            "result": s.result,
            "confidence_level": s.confidence_level,
            "confidence_score": s.confidence_score,
        }
        for s in screenings
    ]

@router.get("/progress")
def screening_progress(
    db: Session = Depends(get_db),
    user = Depends(get_current_user),
):
    screenings = (
        db.query(Screening)
        .filter(Screening.patient_id == user.id)
        .order_by(Screening.created_at.asc())
        .all()
    )

    trend_data = calculate_trend(screenings)

    return {
        "trend": trend_data["trend"],
        "delta": trend_data["delta"],
        "history": [
            {
                "date": s.created_at,
                "prob_cataract": s.prob_cataract,
                "result": s.result,
            }
            for s in screenings
        ]
    }


@router.get("/{screening_id}")
def get_screening_detail(
    screening_id: str,
    db: Session = Depends(get_db),
    user = Depends(get_current_user),
):
    screening = (
        db.query(Screening)
        .filter(Screening.id == screening_id)
        .first()
    )
    
    if not screening:
        raise HTTPException(status_code=404, detail="Screening not found")

    if user.role.upper() != "DOCTOR" and screening.patient_id != user.id:
        raise HTTPException(status_code=403, detail="Access denied")


    referral = (
        db.query(Referral)
        .filter(Referral.screening_id == screening.id)
        .first()
    )

    response = {
        "screening_id": screening.id,
        "created_at": screening.created_at,
        "image_url": screening.image_url,
        "prob_normal": screening.prob_normal,
        "prob_cataract": screening.prob_cataract,
        "decision": {
            "result": screening.result,
            "confidence_level": screening.confidence_level,
            "confidence_score": screening.confidence_score,
            "message": screening.explanation["message"],
        },
        "status": screening.status,
    }

    if referral:
        response["referral"] = {
            "specialty": referral.specialty,
            "urgency": referral.urgency,
            "reason": referral.reason,
        }

    if screening.doctor_decision:
        response["doctor_review"] = {
            "decision": screening.doctor_decision,
            "notes": screening.doctor_notes,
            "reviewed_at": screening.reviewed_at,
        }

    return response

