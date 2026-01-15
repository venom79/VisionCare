import os
import json
import numpy as np
import tensorflow as tf
import requests
from PIL import Image
from pathlib import Path
from app.core.config import settings

BASE_DIR = Path(__file__).resolve().parent.parent
ML_DIR = BASE_DIR / "ml"
MODEL_PATH = ML_DIR / "visioncare_model.h5"
LABELS_PATH = ML_DIR / "labels.json"

MODEL_URL = settings.MODEL_URL

_model = None  # singleton


def load_model_once():
    global _model

    if _model is not None:
        return _model

    ML_DIR.mkdir(parents=True, exist_ok=True)

    if not MODEL_PATH.exists():
        if not MODEL_URL:
            raise RuntimeError("MODEL_URL env var not set")

        print("Downloading model from Hugging Face...")
        r = requests.get(MODEL_URL, stream=True, timeout=120)
        r.raise_for_status()

        tmp_path = MODEL_PATH.with_suffix(".tmp")

        with open(tmp_path, "wb") as f:
            for chunk in r.iter_content(8192):
                if chunk:
                    f.write(chunk)

        tmp_path.rename(MODEL_PATH)

        print("Model download complete")

    print("Loading model into memory...")
    _model = tf.keras.models.load_model(MODEL_PATH)
    return _model


with open(LABELS_PATH) as f:
    LABELS = json.load(f)


def preprocess_image(image_path: str):
    img = Image.open(image_path).convert("RGB")
    img = img.resize((224, 224))
    img = np.array(img, dtype=np.float32) / 255.0
    return np.expand_dims(img, axis=0)


def run_inference(image_path: str):
    model = load_model_once()

    input_tensor = preprocess_image(image_path)
    pred = model.predict(input_tensor, verbose=0)[0][0]

    return {
        "prob_normal": round(float(pred), 3),
        "prob_cataract": round(float(1.0 - pred), 3),
    }
