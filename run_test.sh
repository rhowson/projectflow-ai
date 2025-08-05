#!/bin/bash

# ProjectFlow AI - Quick Test Run
# This script assumes you've set the API key in app_constants.dart for testing

echo "🧪 ProjectFlow AI - Quick Test Run"
echo "=================================="
echo ""
echo "This script assumes you've already set your API key in:"
echo "lib/core/constants/app_constants.dart (_testingApiKey)"
echo ""

# Check if the user wants to run on a specific platform
PLATFORM="${1:-web}"

case $PLATFORM in
  "web"|"chrome")
    echo "🌐 Running on Web (Chrome)..."
    flutter run -d chrome --web-port=8080
    ;;
  "ios")
    echo "📱 Running on iOS..."
    # Check available devices and pick the first iOS device/simulator
    DEVICE_ID=$(flutter devices | grep -E "(iPhone|iOS)" | head -1 | cut -d'•' -f2 | xargs)
    if [ -z "$DEVICE_ID" ]; then
      echo "❌ No iOS devices found. Make sure you have an iOS simulator running or iPhone connected."
      exit 1
    fi
    echo "Using device: $DEVICE_ID"
    flutter run -d "$DEVICE_ID"
    ;;
  "android")
    echo "🤖 Running on Android..."
    flutter run -d android
    ;;
  *)
    echo "❌ Unknown platform: $PLATFORM"
    echo "Usage: ./run_test.sh [web|ios|android]"
    echo "Example: ./run_test.sh ios"
    exit 1
    ;;
esac