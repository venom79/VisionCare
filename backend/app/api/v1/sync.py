from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime

from app.api.deps import get_db, get_current_user
from app.models.screening import Screening
from app.models.referral import Referral
from app.services.sync_service import process_offline_screening
from app.services.referral_service import create_referral_data

router = APIRouter(prefix="/sync", tags=["Offline Sync"])


@router.post("/batch")
def sync_batch(
    payload: dict,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    device_id = payload.get("device_id")
    screenings = payload.get("screenings", [])

    if not device_id or not isinstance(screenings, list) or not screenings:
        raise HTTPException(status_code=400, detail="Invalid sync payload")

    results = []

    for item in screenings:
        # ✅ Mandatory field validation
        required_fields = ("local_id", "prob_cataract", "device_created_at")
        if not all(field in item for field in required_fields):
            raise HTTPException(
                status_code=400,
                detail="Each screening must include local_id, prob_cataract, device_created_at"
            )

        local_id = item["local_id"]
        prob_cataract = float(item["prob_cataract"])

        # 🔒 Idempotency check
        existing = db.query(Screening).filter(
            Screening.local_id == local_id,
            Screening.device_id == device_id,
            Screening.patient_id == user.id
        ).first()

        if existing:
            results.append({
                "local_id": local_id,
                "server_id": existing.id,
                "duplicate": True
            })
            continue

        # 🧠 Process offline result
        processed = process_offline_screening(prob_cataract)
        decision = processed["decision"]

        # 📝 Create screening
        screening = Screening(
            patient_id=user.id,
            device_id=device_id,
            local_id=local_id,
            device_created_at=datetime.fromisoformat(item["device_created_at"]),

            image_url="offline",
            prob_normal=processed["prob_normal"],
            prob_cataract=processed["prob_cataract"],

            result=decision["result"],
            confidence_score=decision["confidence_score"],
            confidence_level=decision["confidence_level"],
            explanation={"message": decision["message"]},

            status="SYNCED",
        )

        db.add(screening)
        db.flush()  # ensures screening.id exists before referral

        # 🏥 Referral logic
        referral_data = create_referral_data(screening.confidence_level)
        if referral_data:
            referral = Referral(
                screening_id=screening.id,
                specialty=referral_data["specialty"],
                urgency=referral_data["urgency"],
                reason=referral_data["reason"],
            )
            db.add(referral)

        # ✅ SINGLE atomic commit
        db.commit()
        db.refresh(screening)

        results.append({
            "local_id": local_id,
            "server_id": screening.id,
            "referral_created": referral_data is not None
        })

    return {
        "device_id": device_id,
        "synced": results
    }
