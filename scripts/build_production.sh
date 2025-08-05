#!/bin/bash

# ProjectFlow AI - Production Build Script
# This script builds the app for production with all necessary environment variables

set -e  # Exit on any error

echo "🚀 Building ProjectFlow AI for Production..."

# Production environment variables
# Set CLAUDE_API_KEY environment variable before running this script
if [ -z "$CLAUDE_API_KEY" ]; then
  echo "❌ Error: CLAUDE_API_KEY environment variable is not set"
  echo "Please set it with: export CLAUDE_API_KEY=your_api_key_here"
  exit 1
fi

USE_DEMO_MODE="false"
ENVIRONMENT="production"
DEBUG_MODE="false"
ENABLE_ANALYTICS="true"
ENABLE_CRASHLYTICS="true"

# Define common dart-define arguments
DART_DEFINES=(
  "--dart-define=CLAUDE_API_KEY=$CLAUDE_API_KEY"
  "--dart-define=USE_DEMO_MODE=$USE_DEMO_MODE"
  "--dart-define=ENVIRONMENT=$ENVIRONMENT"
  "--dart-define=DEBUG_MODE=$DEBUG_MODE"
  "--dart-define=ENABLE_ANALYTICS=$ENABLE_ANALYTICS"
  "--dart-define=ENABLE_CRASHLYTICS=$ENABLE_CRASHLYTICS"
)

# Function to build for specific platform
build_platform() {
  local platform=$1
  local output_dir="build/production/$platform"
  
  echo "📱 Building for $platform..."
  
  case $platform in
    "web")
      flutter build web "${DART_DEFINES[@]}" --release
      echo "✅ Web build completed: build/web/"
      ;;
    "android")
      flutter build apk "${DART_DEFINES[@]}" --release --split-per-abi
      flutter build appbundle "${DART_DEFINES[@]}" --release
      echo "✅ Android builds completed:"
      echo "   APK: build/app/outputs/flutter-apk/"
      echo "   AAB: build/app/outputs/bundle/release/"
      ;;
    "ios")
      flutter build ios "${DART_DEFINES[@]}" --release --no-codesign
      echo "✅ iOS build completed: build/ios/iphoneos/"
      ;;
    "macos")
      flutter build macos "${DART_DEFINES[@]}" --release
      echo "✅ macOS build completed: build/macos/Build/Products/Release/"
      ;;
    "windows")
      flutter build windows "${DART_DEFINES[@]}" --release
      echo "✅ Windows build completed: build/windows/runner/Release/"
      ;;
    "linux")
      flutter build linux "${DART_DEFINES[@]}" --release
      echo "✅ Linux build completed: build/linux/x64/release/"
      ;;
    *)
      echo "❌ Unknown platform: $platform"
      exit 1
      ;;
  esac
}

# Parse command line arguments
if [ $# -eq 0 ]; then
  echo "Usage: $0 <platform> [platform2] [platform3] ..."
  echo "Available platforms: web, android, ios, macos, windows, linux, all"
  exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Build for specified platforms
for platform in "$@"; do
  if [ "$platform" = "all" ]; then
    build_platform "web"
    build_platform "android"
    build_platform "ios"
    build_platform "macos"
    # Skip Windows and Linux for now as they might need additional setup
    # build_platform "windows"
    # build_platform "linux"
  else
    build_platform "$platform"
  fi
done

echo ""
echo "🎉 Production build(s) completed successfully!"
echo "📦 Build artifacts are in the respective build/ directories"
echo ""
echo "🔐 Security Note: This build includes production API keys"
echo "🚀 Ready for deployment!"