from fastapi import FastAPI, UploadFile, File
import uvicorn
import torch
import clip
import numpy as np
from PIL import Image
import json
import io

app = FastAPI()

# Load CLIP model
device = "cuda" if torch.cuda.is_available() else "cpu"
model, preprocess = clip.load("ViT-B/32", device=device)

# Load saved horse signatures (rename file if needed)
with open("horse_signatures.json", "r") as f:
    horse_signatures = json.load(f)

# Convert lists back to numpy arrays
for k in horse_signatures:
    horse_signatures[k] = np.array(horse_signatures[k])

def get_embedding_from_bytes(image_bytes):
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    image = preprocess(image).unsqueeze(0).to(device)

    with torch.no_grad():
        embedding = model.encode_image(image)

    embedding = embedding.cpu().numpy().flatten()
    return embedding / np.linalg.norm(embedding)

@app.post("/identify")
async def identify(file: UploadFile = File(...)):
    img_bytes = await file.read()
    emb = get_embedding_from_bytes(img_bytes)

    best_match = None
    best_score = -1

    for name, sig in horse_signatures.items():
        score = float(np.dot(emb, sig))
        if score > best_score:
            best_score = score
            best_match = name

    THRESHOLD = 0.85

    if best_score < THRESHOLD:
        return {
            "prediction": "Unknown",
            "confidence": float(best_score)
        }

    return {
        "prediction": best_match,
        "confidence": float(best_score)
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
