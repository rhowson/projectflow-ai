# Claude AI API Key Setup

This document explains how to set up your Claude AI API key to enable live project creation and assessment.

## Quick Start

### Method 1: Testing with Hardcoded Key (Easiest for Testing)

⚠️ **FOR TESTING ONLY - NOT FOR PRODUCTION**

1. Open `lib/core/constants/app_constants.dart`
2. Find the line: `static const String _testingApiKey = '';`
3. Replace with your API key: `static const String _testingApiKey = 'sk-ant-api03-your-key-here';`
4. Run the app normally:
   ```bash
   flutter run -d chrome --web-port=8080
   # or
   flutter run  # for iOS/Android
   ```

🚨 **SECURITY WARNING**: Never commit real API keys to version control! Remember to remove the key before committing.

### Method 2: Environment Variables (Recommended for Production)

#### Web Browser (Chrome)

##### Option 1: Using the Script
```bash
./run_with_api.sh sk-ant-api03-your-actual-key-here
```

##### Option 2: Manual Flutter Command
```bash
flutter run -d chrome --web-port=8080 \
    --dart-define=CLAUDE_API_KEY=sk-ant-api03-your-actual-key-here \
    --dart-define=USE_DEMO_MODE=false
```

#### iOS Device/Simulator

##### Option 1: Using the iOS Script
```bash
# Run on physical iPhone (default)
./run_ios_with_api.sh sk-ant-api03-your-actual-key-here

# Run on iPhone simulator
./run_ios_with_api.sh sk-ant-api03-your-actual-key-here simulator

# Run on physical iPhone (explicit)
./run_ios_with_api.sh sk-ant-api03-your-actual-key-here physical
```

##### Option 2: Manual Flutter Command for iOS
```bash
# Physical iPhone
flutter run -d 00008110-000621990CC3401E \
    --dart-define=CLAUDE_API_KEY=sk-ant-api03-your-actual-key-here \
    --dart-define=USE_DEMO_MODE=false

# iPhone Simulator
flutter run -d 503A304A-4023-4A1B-B33C-515D3873FBAB \
    --dart-define=CLAUDE_API_KEY=sk-ant-api03-your-actual-key-here \
    --dart-define=USE_DEMO_MODE=false
```

##### Option 3: Testing with Hardcoded Key (iOS)
If you've set the `_testingApiKey` in `app_constants.dart`, you can simply run:
```bash
flutter run  # Will automatically pick up your testing API key
```

## Getting Your Claude API Key

1. Go to [Anthropic Console](https://console.anthropic.com/)
2. Sign up or log in to your account
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key (it starts with `sk-ant-api03-`)

## Verification

Once the app starts, check the console output for:
```
🔑 API Key Debug:
  Raw key: "sk-ant-api03-..."
  Key length: 108
  Key is empty: false
  Starts with sk-ant-api: true
  Is valid: true
```

If `Is valid: true`, the app will use the live Claude API for project creation.
If `Is valid: false`, the app will fallback to demo mode with mock data.

## Demo Mode vs Live Mode

### Demo Mode (No API Key)
- Uses mock data for project assessment
- Generates fake context questions
- Creates sample project breakdowns
- No actual API calls to Claude

### Live Mode (With Valid API Key)
- Real AI-powered project assessment
- Intelligent context questions based on your project
- Detailed project breakdowns with phases and tasks
- Actual API calls to Claude AI

## Troubleshooting

### Issue: App still shows "Demo Mode: true"
**Solution**: Ensure your API key starts with `sk-ant-api` and is passed correctly via `--dart-define`

### Issue: API calls failing
**Solution**: 
1. Verify your API key is valid in Anthropic Console
2. Check your internet connection
3. Ensure you have sufficient API credits

### Issue: Environment variable not working
**Solution**: Use the `--dart-define` method instead, as it's more reliable for Flutter web

## Security Notes

- Never commit your API key to version control
- Don't share your API key publicly
- Use environment variables or secure key management in production
- The API key is only used client-side for this demo app

## Files Modified

The following files handle API key detection:
- `lib/core/constants/app_constants.dart` - API key configuration
- `lib/core/services/claude_ai_service.dart` - API service implementation
- `lib/features/project_creation/providers/project_provider.dart` - Service provider

## Support

If you continue to have issues:
1. Check the Flutter console for error messages
2. Verify the debug output shows your API key is detected
3. Test with a fresh API key from Anthropic Console