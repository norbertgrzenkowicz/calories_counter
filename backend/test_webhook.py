#!/usr/bin/env python3
"""
Test script to verify webhook endpoint is accessible
"""
import requests
import json

# Your backend URL
BACKEND_URL = "https://japer-backend-789863392317.us-central1.run.app"

def test_webhook_endpoint():
    """Test if webhook endpoint is accessible"""
    url = f"{BACKEND_URL}/stripe/webhook"

    # Create a minimal test payload (will fail signature verification, but that's ok)
    test_payload = {
        "id": "evt_test",
        "type": "checkout.session.completed",
        "data": {
            "object": {
                "id": "cs_test",
                "mode": "subscription"
            }
        }
    }

    headers = {
        "Content-Type": "application/json",
        "Stripe-Signature": "test_signature"
    }

    print(f"Testing webhook endpoint: {url}")
    print(f"Payload: {json.dumps(test_payload, indent=2)}")

    try:
        response = requests.post(url, json=test_payload, headers=headers)
        print(f"\nResponse Status: {response.status_code}")
        print(f"Response Body: {response.text}")

        if response.status_code == 400:
            print("\n✓ Endpoint is accessible (signature verification failed as expected)")
        elif response.status_code == 500:
            if "Webhook secret not configured" in response.text:
                print("\n❌ STRIPE_WEBHOOK_SECRET not configured!")
            else:
                print("\n⚠️  Endpoint error:", response.text)
        else:
            print(f"\n⚠️  Unexpected response: {response.status_code}")

    except Exception as e:
        print(f"\n❌ Error connecting to endpoint: {e}")

if __name__ == "__main__":
    test_webhook_endpoint()
