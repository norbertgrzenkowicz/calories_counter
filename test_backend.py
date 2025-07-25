import requests
import base64
import json
from deepeval import evaluate
from deepeval.metrics import GEval
from deepeval.test_case import LLMTestCase, LLMTestCaseParams
import asyncio

def get_food_analysis(image_path):
    """Get food analysis from backend API"""
    with open(image_path, 'rb') as image_file:
        base64_image = base64.b64encode(image_file.read()).decode('utf-8')
    
    response = requests.post(
        'http://localhost:5001/analyze_food',
        headers={'Content-Type': 'application/json'},
        json={'image': base64_image}
    )
    
    if response.status_code == 200:
        return response.json()
    else:
        raise Exception(f"API Error: {response.text}")

def create_calories_test_case(image_path, actual_result):
    """Create test case for calories evaluation"""
    return LLMTestCase(
        input=f"Food analysis for image: {image_path}",
        actual_output=str(actual_result['calories']),
        context=[actual_result['description']]
    )

def create_macronutrients_test_case(image_path, actual_result):
    """Create test case for macronutrients evaluation"""
    return LLMTestCase(
        input=f"Food analysis for image: {image_path}",
        actual_output=actual_result['description'],
        context=[f"Calories: {actual_result['calories']}"]
    )

def create_dish_name_test_case(image_path, actual_result):
    """Create test case for dish name identification"""
    return LLMTestCase(
        input=f"Food identification for image: {image_path}",
        actual_output=actual_result['description'],
        context=[f"Image path: {image_path}"]
    )

def run_deepeval_tests():
    """Run deepeval tests for all three images"""
    
    # Define evaluation metrics
    calories_metric = GEval(
        name="Calories Accuracy",
        criteria="Determine if the calorie estimate is reasonable for the described food item. The estimate should be within a realistic range based on typical portion sizes and food types.",
        evaluation_params=[LLMTestCaseParams.ACTUAL_OUTPUT, LLMTestCaseParams.CONTEXT],
        evaluation_steps=[
            "Extract the calorie value from the output",
            "Consider the food description and typical serving sizes",
            "Assess if the calorie estimate is within a reasonable range (±200 calories)",
            "Evaluate the accuracy based on food type and portion size"
        ],
        model="gpt-4o-mini"
    )
    
    macronutrients_metric = GEval(
        name="Macronutrients Analysis", 
        criteria="Evaluate if the food description adequately identifies key macronutrients (proteins, carbs, fats) present in the dish based on the ingredients and preparation method described.",
        evaluation_params=[LLMTestCaseParams.ACTUAL_OUTPUT],
        evaluation_steps=[
            "Identify protein sources mentioned in the description",
            "Identify carbohydrate sources mentioned in the description", 
            "Identify fat sources mentioned in the description",
            "Assess completeness of macronutrient identification"
        ],
        model="gpt-4o-mini"
    )
    
    dish_name_metric = GEval(
        name="Dish Identification",
        criteria="Assess if the food description correctly identifies the specific dish or food type, including main ingredients and cooking method.",
        evaluation_params=[LLMTestCaseParams.ACTUAL_OUTPUT, LLMTestCaseParams.INPUT],
        evaluation_steps=[
            "Check if the main dish/food type is correctly identified",
            "Verify if key ingredients are accurately described",
            "Assess if cooking method is properly identified",
            "Evaluate overall specificity and accuracy of identification"
        ],
        model="gpt-4o-mini"
    )
    
    # Test images
    test_images = ["f1.jpg", "f2.jpeg", "f3.jpg"]
    
    print("Running DeepEval tests for backend food analysis...")
    
    for image_path in test_images:
        print(f"\n--- Testing {image_path} ---")
        
        try:
            # Get analysis from backend
            result = get_food_analysis(image_path)
            print(f"Description: {result['description']}")
            print(f"Calories: {result['calories']}")
            
            # Create test cases
            calories_test = create_calories_test_case(image_path, result)
            macronutrients_test = create_macronutrients_test_case(image_path, result)
            dish_name_test = create_dish_name_test_case(image_path, result)
            
            # Evaluate calories
            print("\n🔍 Evaluating Calories...")
            calories_result = evaluate([calories_test], [calories_metric])
            
            # Evaluate macronutrients
            print("\n🔍 Evaluating Macronutrients...")
            macro_result = evaluate([macronutrients_test], [macronutrients_metric])
            
            # Evaluate dish name
            print("\n🔍 Evaluating Dish Identification...")
            dish_result = evaluate([dish_name_test], [dish_name_metric])
            
            print(f"✅ Completed evaluation for {image_path}")
            
        except Exception as e:
            print(f"❌ Error testing {image_path}: {e}")


if __name__ == "__main__":
    # Run deepeval tests
    run_deepeval_tests()
