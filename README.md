# VisionCare – Backend

VisionCare is an **AI-powered eye screening platform** designed to detect cataracts early, support offline usage, and integrate doctors into the diagnosis workflow.

This repository currently contains the **backend system**.  
The frontend (Flutter mobile app) will be added later.

---

## 🎯 Problem VisionCare Solves

- Cataracts often go undiagnosed until late stages
- Many regions lack continuous internet access
- AI predictions need doctor validation, not blind trust

VisionCare addresses this with:
- AI-assisted screening
- Offline-first architecture
- Doctor review & follow-ups

---

## ✅ Features Implemented (Backend)

### 🧠 AI Cataract Screening
- Image-based screening using a trained ML model
- Outputs:
  - Cataract probability
  - Confidence score & severity
  - Patient-friendly explanation

### 🔐 Authentication & Authorization
- JWT-based authentication
- Roles supported:
  - **PATIENT**
  - **DOCTOR**
- Secure access to all APIs

### 📸 Screening Management
- Upload eye image → AI inference → store result
- Patients can:
  - View screening history
  - View detailed screening results
  - Track progression over time

### 🏥 Referral & Triage System
- Automatic referral generation based on severity
- Urgency levels (NORMAL / URGENT)
- Supports ophthalmology workflows

### 👨‍⚕️ Doctor Review & Override
- Doctors can:
  - Review AI results
  - Override decisions
  - Add medical notes
- Screening status updates after review

### 📡 Offline Sync (Critical Feature)
- Supports **offline-first mobile usage**
- Batch sync endpoint with:
  - Idempotency (no duplicate records)
  - Device-level tracking
  - Conflict-safe syncing

### ⏰ Follow-Up & Progress Tracking
- Automatic follow-up scheduling for medium/high risk cases
- Endpoint to fetch pending follow-ups
- Progress tracking over time

### 📊 Metrics & Overview
- Aggregated statistics for dashboards
- Designed for clinic and admin insights

---

## 🏗️ Tech Stack

- **Framework**: FastAPI
- **Database**: PostgreSQL
- **ORM**: SQLAlchemy
- **Migrations**: Alembic
- **Auth**: JWT (OAuth2 password flow)
- **ML Inference**: TensorFlow / Keras

---


