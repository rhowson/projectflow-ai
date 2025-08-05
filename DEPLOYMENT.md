# ProjectFlow AI - Production Deployment Guide

This guide covers deploying ProjectFlow AI to production with proper Claude AI and Firebase integration.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.19+
- Firebase CLI installed
- Docker (for containerized deployment)
- Claude API key from Anthropic Console

### 1. Environment Setup

Copy the environment template:
```bash
cp .env.example .env
```

Update `.env` with your production values:
```env
ENVIRONMENT=production
CLAUDE_API_KEY=your_claude_api_key_here
USE_DEMO_MODE=false
DEBUG_MODE=false
ENABLE_ANALYTICS=true
ENABLE_CRASHLYTICS=true
```

**Important**: Set your Claude API key as an environment variable:
```bash
export CLAUDE_API_KEY=your_claude_api_key_here
```

### 2. Firebase Configuration

Initialize Firebase (if not already done):
```bash
firebase login
firebase init hosting firestore storage
```

Deploy Firebase rules and configuration:
```bash
firebase deploy --only firestore:rules,storage:rules,firestore:indexes
```

### 3. Build for Production

Use the provided build script:
```bash
# Web deployment
./scripts/build_production.sh web

# Mobile apps
./scripts/build_production.sh android ios

# All platforms
./scripts/build_production.sh all
```

## 🌐 Deployment Options

### Option 1: Firebase Hosting (Recommended)

Build and deploy to Firebase Hosting:
```bash
# Build the web app
./scripts/build_production.sh web

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

Your app will be available at: `https://your-project-id.web.app`

### Option 2: Docker Deployment

Build and run with Docker:
```bash
# Build the Docker image
docker build -t projectflow-ai \
  --build-arg CLAUDE_API_KEY=your_api_key \
  --build-arg USE_DEMO_MODE=false \
  --build-arg ENVIRONMENT=production .

# Run the container
docker run -p 80:8080 projectflow-ai
```

Using Docker Compose:
```bash
# Set environment variables in .env file
docker-compose -f docker-compose.prod.yml up -d
```

### Option 3: Manual Deployment

1. Build the web app:
```bash
./scripts/build_production.sh web
```

2. Upload `build/web/` contents to your web server

3. Configure your web server with the provided `nginx.conf`

## 🔧 Environment Variables

### Required Variables
- `CLAUDE_API_KEY`: Your Claude API key from Anthropic Console
- `ENVIRONMENT`: Set to `production`
- `USE_DEMO_MODE`: Set to `false` for live API

### Optional Variables
- `DEBUG_MODE`: Set to `false` for production
- `ENABLE_ANALYTICS`: Enable Google Analytics
- `ENABLE_CRASHLYTICS`: Enable crash reporting

## 🔐 Security Configuration

### Firebase Security Rules

The deployment includes production-ready security rules:
- **Firestore**: Users can only access their projects and teams
- **Storage**: File upload restrictions and size limits
- **Authentication**: Anonymous auth with proper user isolation

### Content Security Policy

The nginx configuration includes CSP headers allowing:
- Claude AI API calls to `api.anthropic.com`
- Firebase services
- Google Fonts and APIs
- Restricted script execution

## 📱 Mobile App Deployment

### Android (Google Play)

1. Build the app bundle:
```bash
./scripts/build_production.sh android
```

2. Upload `build/app/outputs/bundle/release/app-release.aab` to Google Play Console

### iOS (App Store)

1. Build for iOS:
```bash
./scripts/build_production.sh ios
```

2. Open in Xcode and archive for distribution

## 🚀 CI/CD Pipeline

### GitHub Actions Example

```yaml
name: Deploy to Production
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      
      - name: Build Web App
        run: |
          flutter build web --release \
            --dart-define=CLAUDE_API_KEY=${{ secrets.CLAUDE_API_KEY }} \
            --dart-define=USE_DEMO_MODE=false \
            --dart-define=ENVIRONMENT=production
      
      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          projectId: your-firebase-project-id
```

## 📊 Monitoring and Analytics

### Firebase Analytics
- User engagement tracking
- Feature usage analytics  
- Performance monitoring

### Error Tracking
- Firebase Crashlytics for crash reporting
- Custom error logging in production

### Performance Monitoring
- Core Web Vitals tracking
- API response time monitoring
- User experience metrics

## 🔄 Updates and Maintenance

### Hot Fixes
```bash
# Build and deploy quickly
./scripts/build_production.sh web && firebase deploy --only hosting
```

### Version Updates
1. Update version in `pubspec.yaml`
2. Update `APP_VERSION` in constants
3. Build and deploy
4. Tag the release in git

## 🆘 Troubleshooting

### Common Issues

**Claude AI 400 Errors:**
- Verify API key is correct
- Check rate limits
- Ensure proper environment variables

**Firebase Permission Errors:**
- Review Firestore security rules
- Check user authentication status
- Verify project configuration

**Build Failures:**
- Clear Flutter cache: `flutter clean`
- Update dependencies: `flutter pub get`
- Check dart-define variables

### Health Checks

The deployment includes health check endpoints:
- `/health` - Basic health status
- Firebase connection test in app initialization

## 📞 Support

For deployment issues:
1. Check the troubleshooting section above
2. Review Firebase console for errors
3. Check Claude API usage in Anthropic Console
4. Verify all environment variables are set correctly

---

**🎉 Your ProjectFlow AI app is now ready for production!**

**Live Features:**
- ✅ Real Claude AI project assessment
- ✅ Firebase real-time database
- ✅ Secure user authentication
- ✅ Team collaboration
- ✅ Cross-platform support
- ✅ Production-grade security