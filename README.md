# VisionCare – AI-Powered Eye Screening Platform

VisionCare is an **AI-powered cataract screening platform** designed to support early detection and doctor-assisted diagnosis through a mobile-first experience.

This repository contains the **complete working system**:
- Flutter Android app
- Flutter web app
- FastAPI backend with AI inference

---

## 🚀 Try VisionCare (Recommended)

### 📱 Download Android App (APK)
👉 **Direct Download:**  
https://github.com/venom79/VisionCare/releases/download/v1.0/VisionCare-v1.1.apk

**How to install:**
1. Download the APK on your Android phone  
2. Open the file  
3. Allow *Install from unknown sources* if prompted  
4. Install and launch VisionCare  

> This is the **primary way to test VisionCare**, including camera-based screening.

---

### 🌐 Web Version
👉 https://vision-care-dun.vercel.app  

> The web version demonstrates UI, authentication, dashboards, and workflows.  
> Camera-based screening is best experienced on mobile.

---

## 🎯 Problem VisionCare Addresses

- Cataracts often go undiagnosed until advanced stages
- Screening access is limited in many regions
- AI predictions require medical oversight

VisionCare combines **AI-assisted screening + doctor review** to improve early detection.

---

## ✅ Implemented Features (Current Build)

### 🧠 AI Cataract Screening
- Image-based eye screening
- Outputs:
  - Cataract probability
  - Severity level
  - Clear patient-friendly explanation

### 👨‍⚕️ Doctor Review Workflow
- Doctors can:
  - Review AI screening results
  - Approve or override predictions
  - Add medical notes
- Maintains human-in-the-loop diagnosis

### 📊 Patient History & Progress
- Patients can view:
  - Screening history
  - Past results
  - Progress over time

### 🔐 Secure Authentication
- JWT-based authentication
- Roles supported:
  - **PATIENT**
  - **DOCTOR**

### 📈 Metrics & Overview
- Backend provides aggregated statistics for doctor dashboards

---

## 🧩 Designed / Planned Features (Architecture-Level)

> These features are **part of the system design** and architecture planning, as described in the project presentation.

### 📡 Offline-First Support (Planned)
- Intended to allow screening without internet
- Local storage + later sync to backend
- Conflict-safe syncing for medical records

---

## 🏗️ Tech Stack

- **Frontend**: Flutter (Android + Web)
- **Backend**: FastAPI
- **Database**: PostgreSQL
- **Auth**: JWT (OAuth2)
- **AI/ML**: TensorFlow / Keras

---

## 🏁 Hackathon Note

- ✅ Core screening, authentication, and doctor review are fully implemented
- 🧠 Offline-first support is part of the **system design**, not yet implemented
- 📱 Android app is the recommended evaluation path

VisionCare is designed as a **scalable healthcare platform**, with real-world constraints in mind.
