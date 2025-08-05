#!/bin/bash

# ProjectFlow AI - Run on iOS with Claude API Key
# This script helps you run the Flutter app on iPhone with your Claude API key

echo "📱 ProjectFlow AI - Starting on iOS with Claude API"
echo "=================================================="

# Check if API key is provided as argument
if [ -z "$1" ]; then
    echo "❌ Error: No API key provided"
    echo ""
    echo "Usage: ./run_ios_with_api.sh YOUR_CLAUDE_API_KEY [device]"
    echo "Example: ./run_ios_with_api.sh sk-ant-api03-your-key-here"
    echo "Example: ./run_ios_with_api.sh sk-ant-api03-your-key-here simulator"
    echo "Example: ./run_ios_with_api.sh sk-ant-api03-your-key-here physical"
    echo ""
    exit 1
fi

API_KEY="$1"
DEVICE_TYPE="${2:-physical}"  # Default to physical device

# Validate API key format
if [[ ! "$API_KEY" =~ ^sk-ant-api ]]; then
    echo "❌ Error: Invalid API key format"
    echo "Claude API keys should start with 'sk-ant-api'"
    exit 1
fi

echo "✅ API Key validated"

# Set device ID based on type
if [ "$DEVICE_TYPE" = "simulator" ]; then
    DEVICE_ID="503A304A-4023-4A1B-B33C-515D3873FBAB"  # iPhone 15 Simulator
    echo "🔧 Running on iPhone 15 Simulator..."
elif [ "$DEVICE_TYPE" = "physical" ]; then
    DEVICE_ID="00008110-000621990CC3401E"  # Physical iPhone
    echo "🔧 Running on Physical iPhone (wireless)..."
else
    echo "❌ Error: Invalid device type. Use 'simulator' or 'physical'"
    exit 1
fi

echo "📱 Starting Flutter app with API key on iOS..."
echo ""

# Stop any currently running Chrome instance first
pkill -f "flutter run.*chrome" 2>/dev/null || true

# Run Flutter with the API key on iOS
flutter run -d "$DEVICE_ID" \
    --dart-define=CLAUDE_API_KEY="$API_KEY" \
    --dart-define=USE_DEMO_MODE=false \
    --dart-define=ENVIRONMENT=development \
    --dart-define=DEBUG_MODE=true

echo ""
echo "🎉 App started on iOS device!"