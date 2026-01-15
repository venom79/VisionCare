from fastapi import FastAPI
from app.api.v1 import (
    auth,
    doctor,
    doctor_dashboard,
    users,
    screenings,
    referrals,
    followups,
    telemed,
    sync,
    metrics,
    
)

app = FastAPI(
    title="VisionCare API",
    version="1.0.0"
)

app.include_router(auth.router, prefix="/api/v1")
app.include_router(users.router, prefix="/api/v1")
app.include_router(screenings.router, prefix="/api/v1")
app.include_router(referrals.router, prefix="/api/v1")
app.include_router(followups.router, prefix="/api/v1")
app.include_router(telemed.router, prefix="/api/v1")
app.include_router(doctor_dashboard.router, prefix="/api/v1")
app.include_router(sync.router, prefix="/api/v1")
app.include_router(doctor.router, prefix="/api/v1")
app.include_router(metrics.router, prefix="/api/v1")

@app.get("/")
def health_check():
    return {"status": "ok"}
