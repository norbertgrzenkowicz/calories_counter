import requests
import base64
import argparse
import os
import glob
from deepeval import evaluate
from deepeval.metrics import GEval
from deepeval.test_case import LLMTestCase, LLMTestCaseParams
from deepeval.evaluate import DisplayConfig

def get_food_analysis(image_path):
    """Get food analysis from backend API"""
    with open(image_path, 'rb') as image_file:
        base64_image = base64.b64encode(image_file.read()).decode('utf-8')
    
    response = requests.post(
        'http://localhost:5001/analyze_food',
        headers={'Content-Type': 'application/json'},
        json={'image': base64_image, 'filename': image_path}
    )
    
    if response.status_code == 200:
        return response.json()
    else:
        raise Exception(f"API Error: {response.text}")

def create_calories_test_case(image_path, actual_result, expected_range):
    """Create test case for calories evaluation"""
    return LLMTestCase(
        input=f"Food analysis for image: {image_path}",
        actual_output=str(actual_result['calories']),
        expected_output=expected_range,
        context=[f"Image path: {image_path}"]
    )

def run_test_directory(test_dir):
    """Run tests on images from a specific test directory"""
    
    # Define evaluation metrics
    calories_metric = GEval(
        name="Calories Accuracy",
        criteria="Determine if the calorie estimate is reasonable for the given image (e.g., within ±50 calories of a plausible value).",
        evaluation_params=[LLMTestCaseParams.ACTUAL_OUTPUT, LLMTestCaseParams.EXPECTED_OUTPUT],
        evaluation_steps=[
            "Extract the calorie value from the actual output.",
            "Extract the expected calorie range from the expected output.",
            "Check if the actual output calorie value falls within the expected range.",
            "If it falls within the range, the test passes; otherwise, it fails."
        ],
        model="gpt-4o-mini"
    )
    
    # Find all image files in the test directory
    test_dir_path = os.path.join("test_cases", test_dir)
    image_extensions = ["*.jpg", "*.jpeg", "*.png", "*.JPG", "*.JPEG", "*.PNG"]
    image_files = []
    
    for ext in image_extensions:
        image_files.extend(glob.glob(os.path.join(test_dir_path, ext)))
    
    if not image_files:
        print(f"❌ No images found in {test_dir_path}")
        return
    
    print(f"Running tests for {test_dir} with {len(image_files)} images...")
    
    # Special expected ranges for fs directory (original test cases)
    if test_dir == "fs":
        expected_ranges = {
            "f1.jpg": "550-650",
            "f2.jpeg": "500-600", 
            "f3.jpg": "550-650"
        }
    else:
        # Default expected range for other directories
        expected_ranges = {}
        default_range = "400-800"
    
    for image_path in image_files:
        image_name = os.path.basename(image_path)
        print(f"\n--- Testing {image_name} ---")
        
        # Get expected range for this specific image or use default
        if test_dir == "fs":
            expected_range = expected_ranges.get(image_name, "400-800")
        else:
            expected_range = default_range
        
        try:
            # Get analysis from backend
            result = get_food_analysis(image_path)
            print(f"Calories: {result['calories']}")
            
            # Create test cases
            calories_test = create_calories_test_case(image_path, result, expected_range)
            
            # Evaluate calories with suppressed verbose output
            display_config = DisplayConfig(
                verbose_mode=False,
                print_results=False,
                show_indicator=False
            )
            
            calories_result = evaluate(
                test_cases=[calories_test], 
                metrics=[calories_metric],
                display_config=display_config
            )
            
            # Show simplified result
            passed = calories_result.test_results[0].metrics_data[0].success
            status = "✅ PASS" if passed else "❌ FAIL"
            print(f"{status} {image_name}: {result['calories']} calories")
            
        except Exception as e:
            print(f"❌ Error testing {image_name}: {e}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Run food analysis tests')
    parser.add_argument('--test', type=str, help='Test directory name (e.g., rice-breast-beans)')
    
    args = parser.parse_args()
    
    test_dir = args.test if args.test else "fs"
    run_test_directory(test_dir)
