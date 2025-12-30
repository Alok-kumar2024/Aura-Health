import pytesseract
from PIL import Image
import re
from rapidfuzz import process

def clean_text(text: str) -> str:
    text = text.lower()
    text = re.sub(r"[^a-z0-9\s]", " ", text)
    return text

def extract_text_from_image(image: Image.Image) -> str:
    return pytesseract.image_to_string(image)

def detect_drugs_from_text(text: str, known_drugs: list[str]) -> list[str]:
    cleaned = clean_text(text)
    found = set()

    for word in cleaned.split():
        match, score, _ = process.extractOne(word, known_drugs)
        if score >= 85:
            found.add(match.capitalize())

    return list(found)
