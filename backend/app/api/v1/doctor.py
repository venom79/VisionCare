from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime

from app.api.deps import get_db, get_current_user
from app.models.screening import Screening

router = APIRouter(prefix="/doctor", tags=["Doctor Review"])


@router.post("/screenings/{screening_id}/review")
def review_screening(
    screening_id: str,
    payload: dict,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    # 🔒 Role check
    if user.role != "DOCTOR":
        raise HTTPException(
            status_code=403,
            detail="Only doctors can review screenings"
        )

    decision = payload.get("decision")
    notes = payload.get("notes")

    if not decision:
        raise HTTPException(
            status_code=400,
            detail="Doctor decision is required"
        )

    screening = db.query(Screening).filter(
        Screening.id == screening_id
    ).first()

    if not screening:
        raise HTTPException(status_code=404, detail="Screening not found")

    # 🧠 Override model output
    screening.doctor_decision = decision
    screening.doctor_notes = notes
    screening.reviewed_by = user.id
    screening.reviewed_at = datetime.utcnow()
    screening.status = "REVIEWED"

    db.commit()
    db.refresh(screening)

    return {
        "screening_id": screening.id,
        "original_result": screening.result,
        "doctor_decision": screening.doctor_decision,
        "reviewed_at": screening.reviewed_at.isoformat(),
        "doctor_id": user.id
    }


