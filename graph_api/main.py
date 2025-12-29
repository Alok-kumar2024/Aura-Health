from fastapi import FastAPI
from pydantic import BaseModel
from graph_api.db import find_interactions
from graph_api.ai_explainer import explain_interaction

app = FastAPI(title="AuraHealth")

class MealRequest(BaseModel):
    drug: str
    food: str

@app.post("/check-meal")
def check_meal(request: MealRequest):
    interactions = find_interactions(request.drug, request.food)

    if not interactions:
        return {
            "risk": "SAFE",
            "drug": request.drug,
            "food": request.food,
            "message": "No known interaction found."
        }

    results = []

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
