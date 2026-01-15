import requests
from app.core.config import settings

# HF_ML_ENDPOINT = "https://<your-space-name>.hf.space/predict"
HF_ML_ENDPOINT = settings.HF_ML_ENDPOINT

def predict_image(image_path: str):
    with open(image_path, "rb") as f:
        files = {"file": f}
        resp = requests.post(HF_ML_ENDPOINT, files=files, timeout=30)

    if resp.status_code != 200:
        raise RuntimeError(f"ML service failed: {resp.text}")

    return resp.json()
