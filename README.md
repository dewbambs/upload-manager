# Upload Manager

This Flutter project demonstrates an upload manager similar to Google Drive. It uses Firebase Storage to store files and authenticates users anonymously via Firebase Authentication. Uploads can run in the background with pause and resume functionality.

## Features

- Anonymous authentication using `firebase_auth`.
- File upload to Firebase Storage with pause and resume support.
- Background uploads powered by `workmanager`.
- Multiple concurrent uploads.

## Getting Started

1. Configure your Firebase project and download the configuration files (`google-services.json` for Android and `GoogleService-Info.plist` for iOS).
2. Place the configuration files in the respective platform directories (`android/app` and `ios/Runner`).
3. Run `flutter pub get` to fetch dependencies (requires the Flutter SDK).
4. Build and run the app on your device or emulator.

> **Note:** The Flutter SDK is not included in this repository. Install Flutter from [flutter.dev](https://flutter.dev) to run the project.
