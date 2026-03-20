from __future__ import annotations

import base64
import io
import os
from typing import List, Optional

from dotenv import load_dotenv
from fastapi import FastAPI, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from openai import OpenAI
from pydantic import BaseModel, Field

import food_analysis as fa
from subscription_routes import router as subscription_router, webhook_router


load_dotenv()

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(subscription_router)
app.include_router(webhook_router)

api_key = os.getenv("OPENAI_API_KEY")
if not api_key:
    print("WARNING: OPENAI_API_KEY environment variable not set!")
client = OpenAI(api_key=api_key)


class ImageRequest(BaseModel):
    image: Optional[str] = None
    image_url: Optional[str] = None
    filename: Optional[str] = "image.jpg"
    context_text: Optional[str] = None


class TextRequest(BaseModel):
    text: str


class AudioRequest(BaseModel):
    audio: str
    format: Optional[str] = "mp3"


class FoodAnalysisResponseFlat(BaseModel):
    meal_name: str
    calories: int
    protein: int
    carbs: int
    fats: int
    analysis_version: Optional[str] = None
    status: Optional[str] = None
    confidence: Optional[float] = None
    confidence_label: Optional[str] = None
    estimation_method: Optional[str] = None
    clarifying_question: Optional[str] = None
    assumptions: Optional[List[str]] = Field(default=None)
    flags: Optional[List[str]] = Field(default=None)
    items: Optional[List[fa.FoodAnalysisItem]] = Field(default=None)


@app.post("/analyze_food/image", response_model=fa.FoodAnalysisResponseV2)
async def analyze_food_image(
    request: ImageRequest,
    user_id: str = Header(..., alias="X-User-ID"),
):
    if not request.image and not request.image_url:
        raise HTTPException(
            status_code=400,
            detail="Either image or image_url must be provided",
        )

    try:
        result = fa.analyze_image(
            client,
            image_data=request.image or None,
            image_url=None if request.image else request.image_url,
            context_text=request.context_text or None,
        )
        return fa.FoodAnalysisResponseV2(**result)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:
        print(f"Image analysis error: {exc}")
        raise HTTPException(status_code=500, detail="Image analysis failed") from exc


@app.post("/analyze_food/text", response_model=FoodAnalysisResponseFlat)
async def analyze_food_text(
    request: TextRequest,
    user_id: str = Header(..., alias="X-User-ID"),
):
    if not request.text or not request.text.strip():
        raise HTTPException(status_code=400, detail="No text description provided")

    try:
        nutrition = fa.analyze_text(client, request.text)
        return FoodAnalysisResponseFlat(**nutrition)
    except Exception as exc:
        print(f"Text analysis error: {exc}")
        raise HTTPException(status_code=500, detail="Text analysis failed") from exc


@app.post("/analyze_food/audio", response_model=FoodAnalysisResponseFlat)
async def analyze_food_audio(
    request: AudioRequest,
    user_id: str = Header(..., alias="X-User-ID"),
):
    if not request.audio:
        raise HTTPException(status_code=400, detail="No audio provided")

    nutrition = predict_nutrition_from_audio(request.audio, request.format)
    return FoodAnalysisResponseFlat(**nutrition)


@app.post("/analyze_food", response_model=fa.FoodAnalysisResponseV2)
async def analyze_food(
    request: ImageRequest,
    user_id: str = Header(..., alias="X-User-ID"),
):
    return await analyze_food_image(request, user_id)


def parse_nutrition_json(raw_content: str) -> dict:
    return fa.parse_nutrition_json(raw_content)


def predict_nutrition_from_audio(audio_data: str, audio_format: str = "mp3") -> dict:
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
    except Exception as exc:
        print(f"Audio processing error: {exc}")
        return {
            "meal_name": "Unknown Meal",
            "calories": 0,
            "protein": 0,
            "carbs": 0,
            "fats": 0,
        }


if __name__ == "__main__":
    import uvicorn

    port = int(os.getenv("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)
