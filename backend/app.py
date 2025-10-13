from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import os
import json
import re
import base64
import io
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
    filename: Optional[str] = "image.jpg"

class TextRequest(BaseModel):
    text: str

class AudioRequest(BaseModel):
    audio: str
    format: Optional[str] = "mp3"

class FoodAnalysisResponse(BaseModel):
    calories: int
    protein: int
    carbs: int
    fats: int

@app.post("/analyze_food/image", response_model=FoodAnalysisResponse)
async def analyze_food_image(request: ImageRequest):
    """Analyze food from image"""
    if not request.image:
        raise HTTPException(status_code=400, detail="No image provided")

    nutrition = predict_nutrition(request.image)

    return FoodAnalysisResponse(
        calories=nutrition['calories'],
        protein=nutrition['protein'],
        carbs=nutrition['carbs'],
        fats=nutrition['fats']
    )

@app.post("/analyze_food/text", response_model=FoodAnalysisResponse)
async def analyze_food_text(request: TextRequest):
    """Analyze food from text description"""
    if not request.text or not request.text.strip():
        raise HTTPException(status_code=400, detail="No text description provided")

    nutrition = predict_nutrition_from_text(request.text)

    return FoodAnalysisResponse(
        calories=nutrition['calories'],
        protein=nutrition['protein'],
        carbs=nutrition['carbs'],
        fats=nutrition['fats']
    )

@app.post("/analyze_food/audio", response_model=FoodAnalysisResponse)
async def analyze_food_audio(request: AudioRequest):
    """Analyze food from audio description"""
    if not request.audio:
        raise HTTPException(status_code=400, detail="No audio provided")

    nutrition = predict_nutrition_from_audio(request.audio, request.format)

    return FoodAnalysisResponse(
        calories=nutrition['calories'],
        protein=nutrition['protein'],
        carbs=nutrition['carbs'],
        fats=nutrition['fats']
    )

# Backward compatibility: keep old endpoint pointing to image analysis
@app.post("/analyze_food", response_model=FoodAnalysisResponse)
async def analyze_food(request: ImageRequest):
    """Legacy endpoint - redirects to image analysis"""
    return await analyze_food_image(request)


def parse_nutrition_json(raw_content: str) -> dict:
    """Extract and parse nutrition JSON from OpenAI response"""
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

def predict_nutrition(image_data: str) -> dict:
    """Predict nutrition from base64-encoded image"""
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
        raw_content = response.choices[0].message.content.strip()
        return parse_nutrition_json(raw_content)
    except (ValueError, json.JSONDecodeError) as e:
        print(f"JSON parsing error: {e}")
        print(f"Raw content: {response.choices[0].message.content}")
        return {'calories': 0, 'protein': 0, 'carbs': 0, 'fats': 0}

def predict_nutrition_from_text(text_description: str) -> dict:
    """Predict nutrition from text description of food"""
    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "system",
                    "content": "You are a nutrition expert. Analyze text descriptions of food and ingredients to estimate nutritional values. Parse quantities, ingredient names, and cooking methods. Use standard nutrition databases knowledge to calculate totals. Return only a JSON object with calories, protein, carbs, and fats as integers (grams for macronutrients)."
                },
                {
                    "role": "user",
                    "content": f"Estimate the total nutritional content of this food description: \"{text_description}\". Return JSON format: {{\"calories\": number, \"protein\": grams, \"carbs\": grams, \"fats\": grams}}"
                }
            ],
            max_tokens=100
        )
    except Exception as e:
        print(f"OpenAI API error: {e}")
        return {'calories': 0, 'protein': 0, 'carbs': 0, 'fats': 0}

    try:
        raw_content = response.choices[0].message.content.strip()
        return parse_nutrition_json(raw_content)
    except (ValueError, json.JSONDecodeError) as e:
        print(f"JSON parsing error: {e}")
        print(f"Raw content: {response.choices[0].message.content}")
        return {'calories': 0, 'protein': 0, 'carbs': 0, 'fats': 0}

def predict_nutrition_from_audio(audio_data: str, audio_format: str = "mp3") -> dict:
    """Predict nutrition from base64-encoded audio by transcribing then analyzing"""
    try:
        # Decode base64 audio
        audio_bytes = base64.b64decode(audio_data)

        # Create a file-like object for Whisper API
        audio_file = io.BytesIO(audio_bytes)
        audio_file.name = f"audio.{audio_format}"

        # Transcribe audio using Whisper
        transcription = client.audio.transcriptions.create(
            model="whisper-1",
            file=audio_file
        )

        transcribed_text = transcription.text
        print(f"Transcribed audio: {transcribed_text}")

        # Use text-based prediction on transcription
        return predict_nutrition_from_text(transcribed_text)

    except Exception as e:
        print(f"Audio processing error: {e}")
        return {'calories': 0, 'protein': 0, 'carbs': 0, 'fats': 0}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5001)