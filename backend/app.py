from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
from openai import OpenAI

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

api_key = os.getenv('OPENAI_API_KEY')
if not api_key:
    print("WARNING: OPENAI_API_KEY environment variable not set!")
client = OpenAI(api_key=api_key)

class ImageRequest(BaseModel):
    image: str
    filename: str

class FoodAnalysisResponse(BaseModel):
    calories: int
    protein: int
    carbs: int
    fats: int

@app.post("/analyze_food", response_model=FoodAnalysisResponse)
async def analyze_food(request: ImageRequest):
    if not request.image:
        raise HTTPException(status_code=400, detail="No image provided")

    # Use a mock prediction for testing
    nutrition = predict_nutrition(request.image)

    return FoodAnalysisResponse(
        calories=nutrition['calories'],
        protein=nutrition['protein'],
        carbs=nutrition['carbs'],
        fats=nutrition['fats']
    )


def predict_nutrition(image_data: str) -> dict:
    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "system",
                    "content": "You are a nutrition expert. Analyze food images and estimate nutritional values. Account for perspective distortion, plate size variations, camera angles, lighting conditions, and portion visibility. Consider that food may be partially hidden, stacked, or viewed from different angles. Return only a JSON object with calories, protein, carbs, and fats as integers (grams for macronutrients)."
                },
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": "Estimate the nutritional content of this food. Consider perspective, portion size, and any visual distortions. Return JSON format: {\"calories\": number, \"protein\": grams, \"carbs\": grams, \"fats\": grams}"},
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{image_data}"
                            }
                        }
                    ]
                }
            ],
            max_tokens=100
        )
    except Exception as e:
        print(f"OpenAI API error: {e}")
        return {'calories': 0, 'protein': 0, 'carbs': 0, 'fats': 0}
    try:
        import json
        import re
        raw_content = response.choices[0].message.content.strip()
        print(f"Raw OpenAI response: {raw_content}")
        
        # Extract JSON from markdown code blocks if present
        json_match = re.search(r'```json\s*(\{.*?\})\s*```', raw_content, re.DOTALL)
        if json_match:
            json_content = json_match.group(1)
        else:
            json_content = raw_content
            
        result = json.loads(json_content)
        return {
            'calories': int(result.get('calories', 0)),
            'protein': int(result.get('protein', 0)),
            'carbs': int(result.get('carbs', 0)),
            'fats': int(result.get('fats', 0))
        }
    except (ValueError, json.JSONDecodeError) as e:
        print(f"JSON parsing error: {e}")
        print(f"Raw content: {response.choices[0].message.content}")
        return {'calories': 0, 'protein': 0, 'carbs': 0, 'fats': 0}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5001)