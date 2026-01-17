from pathlib import Path
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
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

BASE_DIR = Path(__file__).resolve().parent.parent
UPLOADS_DIR = BASE_DIR / "uploads"


UPLOADS_DIR.mkdir(parents=True, exist_ok=True)


app = FastAPI(
    title="VisionCare API",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount(
    "/uploads",
    StaticFiles(directory=UPLOADS_DIR),
    name="uploads",
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
