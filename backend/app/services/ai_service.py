import json
import numpy as np
import tensorflow as tf
from PIL import Image
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
MODEL_PATH = BASE_DIR / "ml" / "visioncare_model.h5"
LABELS_PATH = BASE_DIR / "ml" / "labels.json"

model = tf.keras.models.load_model(MODEL_PATH)
print(model.output_shape)

with open(LABELS_PATH) as f:
    LABELS = json.load(f)

def preprocess_image(image_path: str):
    img = Image.open(image_path).convert("RGB")
    img = img.resize((224, 224))  # MUST match training
    img = np.array(img) / 255.0
    img = np.expand_dims(img, axis=0)
    return img


def run_inference(image_path: str):
    input_tensor = preprocess_image(image_path)

    pred = model.predict(input_tensor)[0][0]  # scalar sigmoid output

    prob_normal = float(pred)
    prob_cataract = float(1.0 - prob_normal)

    return {
        "prob_normal": round(prob_normal, 3),
        "prob_cataract": round(prob_cataract, 3),
    }
