from ultralytics import YOLO
import io
from PIL import Image

# Load model once on startup
model = YOLO('./graph_api1/best(1).pt') 

def detect_food(image_bytes):
    img = Image.open(io.BytesIO(image_bytes))
    results = model(img)
    
    # Extract labels for items detected with >50% confidence
    detected_names = []
    for r in results:
        for box in r.boxes:
            if box.conf > 0.2:
                name = model.names[int(box.cls)]
                detected_names.append(name.lower())
    
    return list(set(detected_names)) # Return unique items