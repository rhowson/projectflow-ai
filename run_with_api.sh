#!/bin/bash

# ProjectFlow AI - Run with Claude API Key
# This script helps you run the Flutter app with your Claude API key

echo "🚀 ProjectFlow AI - Starting with Claude API"
echo "============================================="

# Check if API key is provided as argument
if [ -z "$1" ]; then
    echo "❌ Error: No API key provided"
    echo ""
    echo "Usage: ./run_with_api.sh YOUR_CLAUDE_API_KEY"
    echo "Example: ./run_with_api.sh sk-ant-api03-your-key-here"
    echo ""
    echo "Or set environment variable:"
    echo "export CLAUDE_API_KEY=sk-ant-api03-your-key-here"
    echo "./run_with_api.sh"
    exit 1
fi

API_KEY="$1"

# Validate API key format
if [[ ! "$API_KEY" =~ ^sk-ant-api ]]; then
    echo "❌ Error: Invalid API key format"
    echo "Claude API keys should start with 'sk-ant-api'"
    exit 1
fi

echo "✅ API Key validated"
echo "🔧 Starting Flutter app with API key..."
echo ""

# Run Flutter with the API key
flutter run -d chrome --web-port=8080 \
    --dart-define=CLAUDE_API_KEY="$API_KEY" \
    --dart-define=USE_DEMO_MODE=false \
    --dart-define=ENVIRONMENT=development

echo ""
echo "🎉 App started! Check the browser at http://localhost:8080"