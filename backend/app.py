from fastapi import FastAPI, HTTPException, Header
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import os
import json
import re
import base64
import io
from openai import OpenAI
from dotenv import load_dotenv
from subscription_routes import router as subscription_router, webhook_router
import food_analysis as fa

# Load environment variables
load_dotenv()

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include subscription routes
app.include_router(subscription_router)
app.include_router(webhook_router)

api_key = os.getenv('OPENAI_API_KEY')
if not api_key:
    print("WARNING: OPENAI_API_KEY environment variable not set!")
client = OpenAI(api_key=api_key)


# ---------------------------------------------------------------------------
# Request / Response models
# ---------------------------------------------------------------------------

class ImageRequest(BaseModel):
    image: Optional[str] = None       # base64-encoded image
    image_url: Optional[str] = None   # HTTPS URL to image in Supabase Storage
    filename: Optional[str] = "image.jpg"
    context_text: Optional[str] = None  # user clarification for refinement


class TextRequest(BaseModel):
    text: str


class AudioRequest(BaseModel):
    audio: str
    format: Optional[str] = "mp3"


class FoodAnalysisItem(BaseModel):
    name: str
    portion_text: str
    calories: int
    protein: int
    carbs: int
    fats: int
    confidence: float


class FoodAnalysisResponseV2(BaseModel):
    # Legacy flat fields (backward compat)
    meal_name: str
    calories: int
    protein: int
    carbs: int
    fats: int
    # New v2 fields
    analysis_version: str = "v2"
    status: str = "complete"
    confidence: float = 1.0
    confidence_label: str = "high"
    estimation_method: str = "image_only"
    clarifying_question: Optional[str] = None
    assumptions: List[str] = []
    flags: List[str] = []
    items: List[FoodAnalysisItem] = []


class FoodAnalysisResponseFlat(BaseModel):
    """Backward-compatible flat response for text/audio endpoints."""
    meal_name: str
    calories: int
    protein: int
    carbs: int
    fats: int


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------

@app.post("/analyze_food/image", response_model=FoodAnalysisResponseV2)
async def analyze_food_image(
    request: ImageRequest,
    user_id: str = Header(..., alias="X-User-ID"),
):
    """Analyze food from image (base64 or URL). Supports clarification refinement."""
    if not request.image and not request.image_url:
        raise HTTPException(status_code=400, detail="Either image or image_url must be provided")

    result = fa.analyze_image(
        client,
        image_data=request.image or None,
        image_url=request.image_url or None,
        context_text=request.context_text or None,
    )
    return FoodAnalysisResponseV2(**result)


@app.post("/analyze_food/text", response_model=FoodAnalysisResponseFlat)
async def analyze_food_text(
    request: TextRequest,
    user_id: str = Header(..., alias="X-User-ID"),
):
    """Analyze food from text description."""
    if not request.text or not request.text.strip():
        raise HTTPException(status_code=400, detail="No text description provided")

    result = fa.analyze_text(client, request.text)
    return FoodAnalysisResponseFlat(**result)


@app.post("/analyze_food/audio", response_model=FoodAnalysisResponseFlat)
async def analyze_food_audio(
    request: AudioRequest,
    user_id: str = Header(..., alias="X-User-ID"),
):
    """Analyze food from audio description (transcribe then analyze)."""
    if not request.audio:
        raise HTTPException(status_code=400, detail="No audio provided")

    nutrition = predict_nutrition_from_audio(request.audio, request.format)
    return FoodAnalysisResponseFlat(**nutrition)


# Backward compatibility: keep old endpoint pointing to image analysis
@app.post("/analyze_food", response_model=FoodAnalysisResponseV2)
async def analyze_food(
    request: ImageRequest,
    user_id: str = Header(..., alias="X-User-ID"),
):
    """Legacy endpoint — proxies to image analysis."""
    return await analyze_food_image(request, user_id)


# ---------------------------------------------------------------------------
# Internal helpers (audio only — image/text now live in food_analysis.py)
# ---------------------------------------------------------------------------

def parse_nutrition_json(raw_content: str) -> dict:
    """Extract and parse nutrition JSON from OpenAI response (kept for benchmark compatibility)."""
    print(f"Raw OpenAI response: {raw_content}")

    json_match = re.search(r'```json\s*(\{.*?\})\s*```', raw_content, re.DOTALL)
    if json_match:
        json_content = json_match.group(1)
    else:
        json_content = raw_content

    result = json.loads(json_content)
    return {
        'meal_name': result.get('meal_name', 'Unknown Meal'),
        'calories': int(result.get('calories', 0)),
        'protein': int(result.get('protein', 0)),
        'carbs': int(result.get('carbs', 0)),
        'fats': int(result.get('fats', 0))
    }


def predict_nutrition_from_audio(audio_data: str, audio_format: str = "mp3") -> dict:
    """Predict nutrition from base64-encoded audio by transcribing then analyzing."""
    try:
        audio_bytes = base64.b64decode(audio_data)
        audio_file = io.BytesIO(audio_bytes)
        audio_file.name = f"audio.{audio_format}"

        transcription = client.audio.transcriptions.create(
            model="whisper-1",
            file=audio_file,
        )
        transcribed_text = transcription.text
        print(f"Transcribed audio: {transcribed_text}")
        return fa.analyze_text(client, transcribed_text)
    except Exception as e:
        print(f"Audio processing error: {e}")
        return {'meal_name': 'Unknown Meal', 'calories': 0, 'protein': 0, 'carbs': 0, 'fats': 0}


if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)
