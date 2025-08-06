import functions_framework
import json
from app import predict_nutrition

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
    
    if request.method == 'POST' and request.path == '/analyze_food':
        try:
            # Get JSON data from request
            request_json = request.get_json(silent=True)
            if not request_json or 'image' not in request_json:
                return (json.dumps({'error': 'No image provided'}), 400, headers)
            
            # Analyze the food
            nutrition = predict_nutrition(request_json['image'])
            
            response_data = {
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