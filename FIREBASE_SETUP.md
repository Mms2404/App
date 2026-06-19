# Firebase Chat Setup Guide

## Step 1 — Create Firebase project

1. Go to https://console.firebase.google.com
2. Click "Add project" → name it (e.g. "MMS App") → Continue
3. Disable Google Analytics if you want (optional) → Create project

## Step 2 — Add Flutter app to Firebase

Install FlutterFire CLI (do this once):
```bash
dart pub global activate flutterfire_cli
```

In your Flutter project root, run:
```bash
flutterfire configure
```

This will:
- Ask you to select your Firebase project
- Ask which platforms (Android / iOS)
- Auto-generate `lib/firebase_options.dart`
- Download `google-services.json` → place in `android/app/`
- Download `GoogleService-Info.plist` → place in `ios/Runner/`

## Step 3 — Add packages to pubspec.yaml

```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
```

Then run:
```bash
flutter pub get
```

## Step 4 — Initialize Firebase in main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}
```

## Step 5 — Enable Phone Auth in Firebase Console

1. Firebase Console → Authentication → Sign-in method
2. Enable "Phone" provider
3. For testing without real SMS, add test numbers:
   - Phone Auth → Scroll down → "Phone numbers for testing"
   - Add: +91 9999999999 → OTP: 123456
   - This avoids burning SMS quota while developing

## Step 6 — Firestore setup

1. Firebase Console → Firestore Database → Create database
2. Start in **test mode** for development (allows all reads/writes)
3. Later switch to production rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users — anyone logged in can read, only owner can write
    match /users/{phone} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
                   && request.auth.token.phone_number.replace('+','') == phone;
    }

    // Chats — only participants can read/write
    match /chats/{chatId} {
      allow read, write: if request.auth != null
        && request.auth.token.phone_number.replace('+','')
           in resource.data.participants;

      match /messages/{msgId} {
        allow read, write: if request.auth != null
          && request.auth.token.phone_number.replace('+','')
             in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
      }
    }
  }
}
```

## Step 7 — Android config

In `android/build.gradle` (project level):
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.2'
}
```

In `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

android {
    ...
    defaultConfig {
        minSdkVersion 21   // Firebase requires 21+
    }
}
```

## Step 8 — iOS config (if needed)

In `ios/Runner/Info.plist`, add:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>YOUR_REVERSED_CLIENT_ID</string>
    </array>
  </dict>
</array>
```
(REVERSED_CLIENT_ID is in GoogleService-Info.plist)

## Done!

Run the app. On the Chat screen:
- Enter your name + phone number → Send OTP
- Enter the 6-digit OTP from SMS (or use your test number)
- You land on the chat list
- Tap the pencil FAB → search for another user → start chatting

