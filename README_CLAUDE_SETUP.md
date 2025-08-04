# Claude AI Setup Instructions

## Getting a Claude API Key

1. **Sign up for Anthropic Claude API**:
   - Go to https://console.anthropic.com/
   - Create an account or sign in
   - Navigate to "API Keys" section
   - Generate a new API key

2. **Configure the API Key**:
   - Open `lib/core/constants/app_constants.dart`
   - Replace `'YOUR_CLAUDE_API_KEY_HERE'` with your actual API key
   - Set `useDemoMode = false` to use the real API

3. **Example Configuration**:
   ```dart
   static const String claudeApiKey = 'sk-ant-api03-your-actual-key-here';
   static const bool useDemoMode = false;
   ```

## Demo Mode vs Real API

- **Demo Mode (default)**: Uses mock data for development and testing
- **Real API Mode**: Makes actual calls to Claude AI for project analysis

## API Usage Notes

- Claude API has usage limits and costs
- Demo mode is free and perfect for development
- Switch to real API when you need actual AI analysis
- The app will automatically detect if you have a valid API key

## Troubleshooting

If you're getting errors with the real API:
1. Check your API key is valid
2. Ensure you have credits in your Anthropic account
3. Check the network connection
4. Review the console logs for specific error messages