from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.api.deps import get_db, get_current_user
from app.models.screening import Screening
from app.models.user import User

router = APIRouter(prefix="/doctor/dashboard", tags=["Doctor Dashboard"])


@router.get("/pending")
def get_pending_screenings(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    if user.role != "DOCTOR":
        raise HTTPException(status_code=403, detail="Doctor access only")

    screenings = (
        db.query(Screening, User)
        .join(User, Screening.patient_id == User.id)
        .filter(
            Screening.status == "COMPLETED",
            Screening.doctor_decision == None
        )
        .order_by(Screening.confidence_score.desc())
        .all()
    )

    return [
        {
            "screening_id": s.id,
            "patient_id": u.id,
            "patient_name": u.full_name,
            "created_at": s.created_at,
            "prob_cataract": s.prob_cataract,
            "confidence_level": s.confidence_level,
            "result": s.result,
        }
        for s, u in screenings
    ]

@router.get("/reviewed")
def get_reviewed_screenings(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    if user.role != "DOCTOR":
        raise HTTPException(status_code=403, detail="Doctor access only")

    screenings = (
        db.query(Screening)
        .filter(
            Screening.reviewed_by == user.id
        )
        .order_by(Screening.reviewed_at.desc())
        .all()
    )

    return [
        {
            "screening_id": s.id,
            "patient_id": s.patient_id,
            "reviewed_at": s.reviewed_at,
            "original_result": s.result,
            "doctor_decision": s.doctor_decision,
            "confidence_level": s.confidence_level,
        }
        for s in screenings
    ]
