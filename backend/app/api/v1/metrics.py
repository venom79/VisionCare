from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.api.deps import get_db, get_current_user
from app.models.screening import Screening
from app.models.referral import Referral

router = APIRouter(prefix="/metrics", tags=["Metrics"])

@router.get("/overview")
def metrics_overview(
    db: Session = Depends(get_db),
    user = Depends(get_current_user),
):
    if user.role not in ["DOCTOR", "ADMIN"]:
        raise HTTPException(status_code=403, detail="Access denied")

    total_screenings = db.query(func.count(Screening.id)).scalar()
    cataract_cases = db.query(func.count(Screening.id))\
        .filter(Screening.result.ilike("%cataract%"))\
        .scalar()

    referrals = db.query(func.count(Referral.id)).scalar()
    reviewed = db.query(func.count(Screening.id))\
        .filter(Screening.status == "REVIEWED")\
        .scalar()

    return {
        "total_screenings": total_screenings,
        "cataract_detected": cataract_cases,
        "referrals_generated": referrals,
        "doctor_reviewed": reviewed,
    }
