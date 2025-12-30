from fastapi import FastAPI, File, Form, UploadFile, HTTPException
from typing import Optional, List
from db import find_interactions
from ai_explainer import explain
from vision import detect_food

app = FastAPI(title="AuraHealth")

@app.post("/check-meal")
async def check_meal(
    drugs: str = Form(...),           
    food_text: Optional[str] = Form(None),
    food_image: Optional[UploadFile] = File(None)
):
    detected_foods = []

    # 1. Vision Logic
    if food_image:
        image_bytes = await food_image.read()
        detected_foods = detect_food(image_bytes)
    
    # 2. Text Logic
    if food_text:
        detected_foods.append(food_text.lower().strip())

    if not detected_foods:
        raise HTTPException(status_code=400, detail="No food identified.")

    # 3. Clean the drug list (Convert "Advil, Tylenol" -> ["Advil", "Tylenol"])
    drug_list = [d.strip() for d in drugs.split(",")]

    results = []
    
    # 4. NESTED LOOP: Check every food against every drug
    for food in detected_foods:
        for drug_name in drug_list:
            # Call your existing function (drug: str, food: str)
            interactions = find_interactions(drug_name, food)
            
            for item in interactions:
                # If your DB returns data, we treat it as an interaction
                if item.get("reason"):
                    ai_text = explain(
                        drug=item["drug"],
                        food=item["food"],
                        relation=item.get("relation"),
                        reason=item["reason"],
                        alternatives=item.get("alternatives")
                    )

                    results.append({
                        "relation": item.get("relation"),
                        "drug": item["drug"],
                        "food": item["food"],
                        "reason": item["reason"],
                        "alternatives": item.get("alternatives"),
                        "ai_explanation": ai_text
                    })

    # 5. FINAL LOGIC: Empty result means safe
    if not results:
        return {
            "risk": "SAFE",
            "drugs_checked": drug_list,
            "foods_checked": detected_foods,
            "message": "No known interaction found."
        }

    return {
        "risk": "DANGER",
        "drugs_checked": drug_list,
        "foods_checked": detected_foods,
        "interactions": results
    }