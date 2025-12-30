from fastapi import FastAPI, UploadFile, File
from PIL import Image
import io

from prescription_image_ocr.ocr_utils import extract_text_from_image, detect_drugs_from_text
from prescription_image_ocr.db import get_all_drug_names


app = FastAPI(title="AuraHealth OCR API")


@app.post("/detect-drugs")
async def detect_drugs(file: UploadFile = File(...)):
    image_bytes = await file.read()
    image = Image.open(io.BytesIO(image_bytes))

    text = extract_text_from_image(image)
    known_drugs = get_all_drug_names()
    detected = detect_drugs_from_text(text, known_drugs)

    return {
        "drugs_detected": detected
    }


@app.get("/")
def root():
    return {"status": "OCR service running"}
