# Mobile Deployment

The Flutter project now includes Android and iOS platform folders.

## Current App Identity

- Display name: `Biology Game`
- Android application ID: `org.charlottehs.biologygame`
- iOS bundle ID: `org.charlottehs.biologygame`

Change the app ID before store submission if your organization wants a different official identifier.

## Android

Requirements:

- Android Studio
- Android SDK and command-line tools
- A connected Android device or emulator

Setup:

```powershell
flutter doctor
flutter doctor --android-licenses
flutter pub get
```

If Flutter cannot find the SDK, set `ANDROID_HOME` to your Android SDK folder. A common Windows SDK path is:

```powershell
$env:ANDROID_HOME="$env:LOCALAPPDATA\Android\Sdk"
```

Run on a phone or emulator:

```powershell
flutter run -d android
```

Build an APK for direct installation:

```powershell
flutter build apk --release
```

Build an Android App Bundle for Google Play:

```powershell
flutter build appbundle --release
```

Before publishing to Google Play, replace debug signing with a release signing key in the Android Gradle config.

## iOS

Requirements:

- macOS
- Xcode
- Apple Developer account
- CocoaPods if required by installed plugins

Setup on a Mac:

```bash
flutter doctor
flutter pub get
cd ios
pod install
cd ..
```

Run on a simulator or device:

```bash
flutter run -d ios
```

Build for App Store/TestFlight:

```bash
flutter build ipa --release
```

Then upload the generated archive using Xcode Organizer or Apple's Transporter app.

In Xcode, open `ios/Runner.xcworkspace`, choose your Apple team, verify the bundle ID, and configure signing before archiving.
