import functions_framework
import json
from app import predict_nutrition, predict_nutrition_from_text, predict_nutrition_from_audio

@functions_framework.http
def yapper_api(request):
    """HTTP Cloud Function entry point"""
    # Set CORS headers
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
    }

    # Handle preflight requests
    if request.method == 'OPTIONS':
        return ('', 204, headers)

    if request.method == 'POST':
        try:
            # Get JSON data from request
            request_json = request.get_json(silent=True)
            if not request_json:
                return (json.dumps({'error': 'No JSON data provided'}), 400, headers)

            nutrition = None

            # Route based on path
            if request.path in ['/analyze_food', '/analyze_food/image']:
                # Image-based analysis
                if 'image' not in request_json:
                    return (json.dumps({'error': 'No image provided'}), 400, headers)
                nutrition = predict_nutrition(request_json['image'])

            elif request.path == '/analyze_food/text':
                # Text-based analysis
                if 'text' not in request_json:
                    return (json.dumps({'error': 'No text description provided'}), 400, headers)
                nutrition = predict_nutrition_from_text(request_json['text'])

            elif request.path == '/analyze_food/audio':
                # Audio-based analysis
                if 'audio' not in request_json:
                    return (json.dumps({'error': 'No audio provided'}), 400, headers)
                audio_format = request_json.get('format', 'mp3')
                nutrition = predict_nutrition_from_audio(request_json['audio'], audio_format)

            else:
                return (json.dumps({'message': 'Yapper API is running'}), 200, headers)

            # Return nutrition data if analysis was performed
            if nutrition:
                response_data = {
                    'meal_name': nutrition['meal_name'],
                    'calories': nutrition['calories'],
                    'protein': nutrition['protein'],
                    'carbs': nutrition['carbs'],
                    'fats': nutrition['fats']
                }
                headers['Content-Type'] = 'application/json'
                return (json.dumps(response_data), 200, headers)

        except Exception as e:
            error_response = {'error': str(e)}
            headers['Content-Type'] = 'application/json'
            return (json.dumps(error_response), 500, headers)

    # Default response for other endpoints
    return (json.dumps({'message': 'Yapper API is running'}), 200, headers)