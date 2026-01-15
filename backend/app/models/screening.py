from sqlalchemy import Column, String, Float, ForeignKey, JSON, DateTime
from app.core.database import Base
from datetime import datetime, timedelta
import uuid

class Screening(Base):
    __tablename__ = "screenings"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))

    patient_id = Column(String, ForeignKey("users.id"), nullable=False)

    # 🔑 Offline sync fields
    device_id = Column(String, nullable=True)
    local_id = Column(String, nullable=True)
    device_created_at = Column(DateTime, nullable=True)

    image_url = Column(String, nullable=False)

    prob_normal = Column(Float, nullable=False)
    prob_cataract = Column(Float, nullable=False)

    result = Column(String, nullable=False)
    confidence_score = Column(Float, nullable=False)
    confidence_level = Column(String, nullable=False)

    explanation = Column(JSON, nullable=False)
    status = Column(String, default="COMPLETED")

     # 🔥 Doctor override fields
    reviewed_by = Column(String, ForeignKey("users.id"), nullable=True)
    doctor_decision = Column(String, nullable=True)
    doctor_notes = Column(String, nullable=True)
    reviewed_at = Column(DateTime, nullable=True)

    next_followup_due = Column(DateTime, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
