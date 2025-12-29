import os
from groq import Groq
import os
from dotenv import load_dotenv
load_dotenv()
client = Groq(api_key=os.getenv("GROQ_API_KEY"))



def explain(drug, food, relation, reason, alternatives):
    if relation == "POSITIVE_INTERACTION":
        tone = "Explain why this food is beneficial and recommended."
    else:
        tone = "Explain why this food should be avoided."

    response = client.chat.completions.create(
        model="llama-3.1-8b-instant",
        temperature=0.3,
        messages = [
    {
        "role": "system",
        "content": (
            "You are a medical explanation assistant for patients. "
            "You NEVER make medical decisions. "
            "You NEVER add new drugs, foods, benefits, or risks. "
            "You ONLY explain the information provided to you. "
            "You strictly follow the interaction type instructions."
        )
    },
    {
        "role": "user",
        "content": f"""
INTERACTION TYPE: {relation}

STRICT RULES:
- If interaction type is POSITIVE_INTERACTION:
  • Explain how the food is beneficial or helpful for the drug.
  • Use a positive, encouraging tone.
  • DO NOT mention risks, interference, avoidance, or warnings.

- If interaction type is NEGATIVE_INTERACTION:
  • Explain why the food should be avoided.
  • Clearly mention the risk using the reason.
  • Clearly suggest the provided alternative.
  • Use a cautionary tone.
  • DO NOT describe the food as beneficial.

Drug: {drug}
Food: {food}
Reason: {reason}
Alternative or guidance: {alternatives}

Explain in 2 or 3 simple, patient-friendly sentences.
"""
    }
]

    )

    return response.choices[0].message.content.strip()
