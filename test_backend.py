import requests
import base64
import json

def test_image(image_path):
    with open(image_path, 'rb') as image_file:
        base64_image = base64.b64encode(image_file.read()).decode('utf-8')
    
    response = requests.post(
        'http://localhost:5001/analyze_food',
        headers={'Content-Type': 'application/json'},
        json={'image': base64_image}
    )
    
    print(f"\n--- Testing {image_path} ---")
    print(f"Status Code: {response.status_code}")
    if response.status_code == 200:
        result = response.json()
        print(f"Description: {result['description']}")
        print(f"Calories: {result['calories']}")
        print(f"Vector Info: {result['vector_info']}")
    else:
        print(f"Error: {response.text}")

if __name__ == "__main__":
    test_image("f1.jpg")
    test_image("f2.jpeg") 
    test_image("f3.jpg")