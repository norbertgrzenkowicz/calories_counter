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

client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

class ImageRequest(BaseModel):
    image: str

class FoodAnalysisResponse(BaseModel):
    description: str
    vector_info: dict
    calories: int

@app.post("/analyze_food", response_model=FoodAnalysisResponse)
async def analyze_food(request: ImageRequest):
    if not request.image:
        raise HTTPException(status_code=400, detail="No image provided")
    
    description = get_food_description(request.image)
    vector_result = get_vector_db_result(description)
    calories = predict_calories(description, vector_result)
    
    return FoodAnalysisResponse(
        description=description,
        vector_info=vector_result,
        calories=calories
    )

def get_food_description(image_data: str) -> str:
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": "Analyze the food item in the image. Your analysis should include: 1. A description of the dish, its ingredients, and cooking style. 2. A classification of the food type (e.g., salad, soup, stir-fry). 3. An estimated breakdown of macronutrients (protein, carbohydrates, fats) in grams."},
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/jpeg;base64,{image_data}"
                        }
                    }
                ]
            }
        ],
        max_tokens=300
    )
    return response.choices[0].message.content

def get_vector_db_result(description: str) -> dict:
    return {"placeholder": "Vector DB integration coming soon", "query": description}

def predict_calories(description: str, vector_info: dict) -> int:
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {
                "role": "system",
                "content": "You are a nutrition expert. Estimate calories based on food description. Return only a number."
            },
            {
                "role": "user",
                "content": f"Food description: {description}\nAdditional info: {vector_info}\nEstimate calories:"
            }
        ],
        max_tokens=50
    )
    try:
        return int(response.choices[0].message.content.strip())
    except ValueError:
        return 0

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5001)
