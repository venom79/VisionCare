from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from datetime import datetime

from app.api.deps import get_db, get_current_user
from app.models.screening import Screening

router = APIRouter(prefix="/followups", tags=["Follow-ups"])


@router.get("/pending")
def get_pending_followups(
    db: Session = Depends(get_db),
    user = Depends(get_current_user),
):
    now = datetime.utcnow()

    followup = (
        db.query(Screening)
        .filter(
            Screening.patient_id == user.id,
            Screening.next_followup_due != None,
            Screening.next_followup_due >= now
        )
        .order_by(Screening.next_followup_due.asc())
        .first()
    )

    if not followup:
        return []

    return [{
        "screening_id": followup.id,
        "due_date": followup.next_followup_due,
        "message": "Monthly eye scan due"
    }]