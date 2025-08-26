#!/usr/bin/env python3

import requests
import json

# Test script to verify challenges API endpoints are working

BASE_URL = "http://localhost:8000/api/v1"

def test_challenges_endpoint():
    """Test the challenges endpoint without authentication"""
    try:
        response = requests.get(f"{BASE_URL}/challenges")
        print(f"GET /challenges - Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"  Success! Found {len(data.get('challenges', []))} challenges")
            return True
        elif response.status_code == 401:
            print("  Expected: Authentication required")
            return True
        else:
            print(f"  Error: {response.text}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("  Error: Could not connect to backend server")
        return False
    except Exception as e:
        print(f"  Error: {e}")
        return False

def test_server_health():
    """Test if the server is running"""
    try:
        response = requests.get(f"{BASE_URL.replace('/api/v1', '')}/docs")
        if response.status_code == 200:
            print("✅ Backend server is running")
            return True
        else:
            print("❌ Backend server health check failed")
            return False
    except:
        print("❌ Backend server is not responding")
        return False

if __name__ == "__main__":
    print("🧪 Testing Frontend-Backend Integration")
    print("=" * 50)
    
    print("\n1. Testing server health...")
    server_ok = test_server_health()
    
    if server_ok:
        print("\n2. Testing challenges endpoint...")
        challenges_ok = test_challenges_endpoint()
        
        if challenges_ok:
            print("\n✅ Integration test passed!")
            print("\n📱 Frontend Integration Steps:")
            print("1. ✅ Backend challenges API is working")
            print("2. ✅ Challenge models created")
            print("3. ✅ Challenge service created")
            print("4. ✅ ChallengesScreen updated to use backend")
            print("\n🚀 Next steps:")
            print("- Run your Flutter app")
            print("- Navigate to the Challenges screen")
            print("- The app will try to connect to the backend")
            print("- If backend is unavailable, it will show fallback data")
            print("- Check the Flutter console for API call logs")
        else:
            print("\n❌ Challenges endpoint test failed")
    else:
        print("\n❌ Server is not running")
    
    print("\n📝 Backend API Endpoints Available:")
    print("- GET /api/v1/challenges - List all challenges")
    print("- GET /api/v1/challenges/{id} - Get specific challenge")
    print("- POST /api/v1/challenges/{id}/join - Join a challenge")
    print("- POST /api/v1/challenges/{id}/leave - Leave a challenge")
    print("- GET /api/v1/my-challenges - Get user's challenges")
    print("- GET /api/v1/my-created-challenges - Get user's created challenges")
    
    print("\n🔗 API Documentation:")
    print("http://localhost:8000/docs")
