import os
from vision import detect_food

def test_vision():
    # Path to your test image
    image_path = "ggginger.jpg"
    
    if not os.path.exists(image_path):
        print(f"Error: Could not find {image_path}. Please add an image to the folder.")
        return

    # Simulate reading the file into bytes (as FastAPI would)
    with open(image_path, "rb") as f:
        image_bytes = f.read()

    print(f"--- Running YOLOv11 on {image_path} ---")
    
    # Call your vision.py function
    try:
        detected_items = detect_food(image_bytes)
        
        if detected_items:
            print(f"SUCCESS! Detected: {', '.join(detected_items)}")
        else:
            print("WARNING: Model ran but detected nothing. Try a clearer image.")
            
    except Exception as e:
        print(f"CRITICAL ERROR: {e}")

if __name__ == "__main__":
    test_vision()