# ProjectFlow AI 🚀

**AI-Powered Project Management Application**

A modern, intelligent project management platform built with Flutter that leverages Claude AI to help break down complex projects into manageable phases and tasks.

![Flutter](https://img.shields.io/badge/Flutter-3.19+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.3+-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Latest-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## ✨ Features

### 🤖 AI-Powered Project Planning
- **Intelligent Project Assessment**: Claude AI analyzes project descriptions and determines complexity
- **Automatic Phase Generation**: Breaks down projects into logical phases and tasks
- **Smart Task Creation**: Generates relevant tasks with dependencies and time estimates
- **Context-Aware Recommendations**: Provides tailored suggestions based on project type

### 📊 Project Management
- **Interactive Dashboard**: Clean, modern interface showing all projects and their status
- **Phase Management**: Organize work into logical phases with progress tracking
- **Task Management**: Create, edit, delete, and track tasks with priorities and due dates
- **Team Collaboration**: Assign tasks to team members and track progress
- **Real-time Sync**: All changes sync automatically with Firebase

### 🎨 Modern UI/UX
- **Responsive Design**: Works seamlessly on mobile, tablet, and desktop
- **Beautiful Animations**: Smooth micro-interactions and transitions
- **Professional Splash Screen**: Custom-designed logo with elegant animations
- **Dark/Light Theme Support**: Comfortable viewing in any environment
- **Accessibility**: Screen reader support and proper contrast ratios

### 🔧 Technical Features
- **Firebase Integration**: Real-time database with offline support
- **Cross-Platform**: Single codebase for iOS, Android, Web, macOS, Windows, Linux
- **State Management**: Riverpod for efficient and scalable state management
- **Routing**: Go Router for declarative navigation
- **Database Persistence**: All data stored securely in Firestore

## 🛠️ Technology Stack

- **Frontend**: Flutter 3.19+ with Dart 3.3+
- **AI Integration**: Anthropic Claude API
- **Backend**: Firebase (Firestore, Auth, Storage)
- **State Management**: Riverpod
- **Routing**: Go Router
- **UI Framework**: Material Design 3
- **Animation**: Custom animations with Flutter's animation framework

## 📱 Supported Platforms

- ✅ **Web** (Chrome, Firefox, Safari, Edge)
- ✅ **iOS** (13.0+)
- ✅ **Android** (API 21+)
- ✅ **macOS** (10.14+)
- ✅ **Windows** (Windows 10+)
- ✅ **Linux** (Ubuntu 18.04+)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.19 or higher
- Dart SDK 3.3 or higher
- Firebase project with Firestore enabled
- Claude AI API key (optional, for AI features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/projectflow-ai.git
   cd projectflow-ai
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Firestore Database
   - Enable Authentication (Anonymous)
   - Download configuration files and place in appropriate directories

4. **Run the app**
   ```bash
   flutter run -d chrome  # For web
   flutter run -d ios     # For iOS
   flutter run -d android # For Android
   ```

## 🏗️ Project Structure

```
lib/
├── main.dart                     # App entry point
├── app.dart                      # Main app configuration
├── core/                         # Core functionality
│   ├── constants/               # App constants and API keys
│   ├── models/                  # Data models
│   ├── services/                # Business logic services
│   └── widgets/                 # Reusable core widgets
├── features/                    # Feature modules
│   ├── auth/                   # Authentication
│   ├── dashboard/              # Main dashboard
│   ├── project_creation/       # Project creation flow
│   ├── splash/                 # Splash screen
│   └── task_management/        # Task management
├── shared/                     # Shared resources
│   ├── animations/            # Custom animations
│   ├── theme/                 # App theming
│   └── widgets/               # Reusable UI widgets
└── routes/                     # App routing configuration
```

## 🎯 Key Features

### AI-Powered Project Creation
1. **Describe Your Project**: Simply describe what you want to build
2. **AI Analysis**: Claude AI analyzes complexity and project type
3. **Smart Breakdown**: Automatically generates phases and tasks
4. **Ready to Go**: Start managing your project immediately

### Task Management
- **Visual Task Board**: Kanban-style board for larger screens
- **Mobile-Optimized Lists**: Clean task lists for mobile devices
- **Quick Actions**: Mark complete, edit, delete, or move tasks
- **Progress Tracking**: Visual indicators for phase and project completion

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev) for the amazing framework
- [Anthropic](https://anthropic.com) for Claude AI integration
- [Firebase](https://firebase.google.com) for backend services

---

**Built with ❤️ using Flutter and Claude AI**
