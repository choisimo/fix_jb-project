import requests
import json
import os
import base64

# --- Configuration ---
# Provided by the user
API_URL = "https://serverless.roboflow.com/infer/workflows/fixjeonbukapplication/detect-count-and-visualize"
# It's recommended to move this to an environment variable (.env file) for security
API_KEY = "Hiz9aSgGAYiGEAhpJCRO"

def analyze_local_image(image_path: str):
    """
    Analyzes a local image file using the Roboflow serverless API via a direct HTTP request.
    This function reads a local image, base64 encodes it, and sends it to the API.
    """
    if not os.path.exists(image_path):
        print(f"❌ File not found: {image_path}")
        return

    # 1. Read and Base64 encode the image
    try:
        with open(image_path, "rb") as image_file:
            encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
    except Exception as e:
        print(f"❌ Error reading or encoding the image file: {e}")
        return

    # 2. Construct the request payload
    headers = {
        'Content-Type': 'application/json'
    }
    payload = {
        "api_key": API_KEY,
        "inputs": {
            "image": {
                "type": "base64",
                "value": encoded_string
            }
        }
    }

    # 3. Make the API call
    print(f"🚀 Sending request for '{os.path.basename(image_path)}' to Roboflow API...")
    try:
        response = requests.post(API_URL, headers=headers, json=payload, timeout=30) # Add a 30-second timeout
        response.raise_for_status()  # Raise an exception for bad status codes (4xx or 5xx)
    except requests.exceptions.RequestException as e:
        print(f"❌ API request failed: {e}")
        # Try to print the response body for more details if it exists
        if e.response is not None:
            print(f"    Response Body: {e.response.text}")
        return

    # 4. Print the result
    print("✅ Request successful!")
    result_json = response.json()

    print("\n--- Analysis Result (JSON) ---")
    print(json.dumps(result_json, indent=4, ensure_ascii=False))
    print("----------------------------")


if __name__ == "__main__":
    # Analyze a sample image from the test_images directory
    # You can change this to any other image file.
    sample_image = "test_images/pothole_1.jpg"

    analyze_local_image(sample_image)
