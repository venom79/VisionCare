from sqlalchemy import Column, String, ForeignKey
from app.core.database import Base
import uuid

class Referral(Base):
    __tablename__ = "referrals"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    screening_id = Column(String, ForeignKey("screenings.id"), nullable=False)

    specialty = Column(String, nullable=False)  # OPHTHALMOLOGY
    urgency = Column(String, nullable=False)    # URGENT / ROUTINE
    reason = Column(String, nullable=False)
