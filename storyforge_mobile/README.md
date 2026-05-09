# StoryForge Mobile

The mobile companion for StoryForge, a real-time AI-collaborative storytelling platform. Built with Flutter, Riverpod, and GoRouter.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio / Xcode (for emulators)
- A running StoryForge backend

### Setup
1. Clone the repository.
2. Navigate to `mobile/storyforge_mobile`.
3. Run `flutter pub get`.
4. Run code generation:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

### 🌍 Configuration
To connect to your backend, update the `baseUrl` in `lib/core/constants/api_constants.dart`:
```dart
static const String baseUrl = 'http://YOUR_MACHINE_IP:8000';
static const String wsBaseUrl = 'ws://YOUR_MACHINE_IP:8000';
```
*Note: Using `127.0.0.1` or `localhost` will not work on physical devices or some emulators. Use your local network IP.*

## 🏗️ Architecture
The project follows a **Feature-First Layered Architecture**:
- **Core**: Global themes, router, networking, and storage.
- **Features**: Modularized by business domain (Auth, Dashboard, Story).
  - **Data**: Models (Freezed) and Repositories (Dio).
  - **Presentation**: UI Screens, Widgets, and State Management (Riverpod Notifiers).
- **Shared**: Reusable UI components like custom buttons and text fields.

## 📱 Running the App
- **Emulator**: Select a device in your IDE and press F5 or run `flutter run`.
- **Physical Device**: Enable USB debugging on your Android/iOS device and run `flutter run`.

## ✨ Features
- Real-time storytelling via WebSockets.
- AI Branching & Voting system.
- Immersive Dark Theme with custom Cinzel typography.
- Persistent authentication with JWT and secure storage.
