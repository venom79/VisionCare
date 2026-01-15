from sqlalchemy import Column, String, ForeignKey, Float
from app.core.database import Base
import uuid

class FollowUp(Base):
    __tablename__ = "followups"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    patient_id = Column(String, ForeignKey("users.id"))
    previous_score = Column(Float)
    current_score = Column(Float)
    trend = Column(String)
