from fastapi import FastAPI
from pydantic import BaseModel
from graph_api.db import find_interactions,drug_exists
from graph_api.ai_explainer import explain


app = FastAPI(title="AuraHealth")

class MealRequest(BaseModel):
    drug: str
    food: str

@app.post("/check-meal")
def check_meal(request: MealRequest):
    results = []
    if not drug_exists(request.drug):
      
        results.append({
            "relation": "UNKNOWN",
            "drug": request.drug,
            "food": request.food,
            "reason": "drug not found in database",
            "alternatives": "None needed.",
            "ai_explanation": "This medication is not present in our database. Please consult your doctor or pharmacist."
        })
        return {
        "drug": request.drug,
        "food": request.food,
        "interactions": results
    }

    interactions = find_interactions(request.drug, request.food)

    if not interactions:
       
        results.append({
            "relation": "SAFE",
            "drug": request.drug,
            "food": request.food,
            "reason": "No known interaction found.",
            "alternatives": "None needed.",
            "ai_explanation": "This food item has no interaction with this drug ."
        })
        return {
        "drug": request.drug,
        "food": request.food,
        "interactions": results
    }

    

    for item in interactions:
        ai_text = explain(
            drug=item["drug"],
            food=item["food"],
            relation=item["relation"],
            reason=item["reason"],
            alternatives=item["alternatives"]
        )

        results.append({
            "relation": item["relation"],
            "drug": item["drug"],
            "food": item["food"],
            "reason": item["reason"],
            "alternatives": item["alternatives"],
            "ai_explanation": ai_text
        })

    return {
        "drug": request.drug,
        "food": request.food,
        "interactions": results
    }

@app.get("/")
def root():
    return {"status": "AuraHealth backend running"}
