# Installation Guide

## For Development

### 1. Install Flutter

Download and install Flutter SDK from: https://flutter.dev/docs/get-started/install

Verify installation:
```bash
flutter doctor
```

### 2. Setup Development Environment

#### For Android:
- Install Android Studio
- Install Android SDK
- Accept Android licenses: `flutter doctor --android-licenses`

#### For iOS (macOS only):
- Install Xcode from App Store
- Install CocoaPods: `sudo gem install cocoapods`
- Open Xcode and accept license agreements

### 3. Clone and Run

```bash
cd finger_picker_flutter
flutter pub get
flutter run
```

## For End Users

### Android

1. Download the APK file from releases
2. Enable "Install from Unknown Sources" in Settings
3. Tap the APK file to install
4. Open "Finger Picker" app

### iOS

1. Download the IPA file from releases
2. Use AltStore or TestFlight to install
3. Trust the developer certificate in Settings > General > Device Management
4. Open "Finger Picker" app

## Building from Source

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS
```bash
flutter build ios --release
# Then open Xcode and archive for distribution
```

## Troubleshooting

### Multi-touch not working
- Ensure you're testing on a real device (emulators have limited touch support)
- Check device settings for touch sensitivity

### App crashes on startup
- Run `flutter clean && flutter pub get`
- Ensure you have the latest Flutter version: `flutter upgrade`

### Build errors
- Clear build cache: `flutter clean`
- Update dependencies: `flutter pub upgrade`
- Check Flutter doctor: `flutter doctor -v`
