FROM python:3.11-slim

# Install system dependencies for OCR
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Python dependencies
COPY ./prescription_image_ocr/requirements.txt .
RUN pip install --no-cache-dir -r ./prescription_image_ocr/requirements.txt

# Copy application code
COPY . .

# Start FastAPI app
CMD ["uvicorn", "prescription_image_ocr.main:app", "--host", "0.0.0.0", "--port", "10000"]
