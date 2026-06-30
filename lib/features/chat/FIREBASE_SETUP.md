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

This step is the #1 source of errors. Follow it exactly.

### 5a. Enable the Phone sign-in provider

1. Firebase Console → your project → **Authentication** → **Sign-in method** tab
2. Find **Phone** in the provider list → click it → toggle **Enable** → **Save**

If you skip this, you get exactly the error you saw:
```
This operation is not allowed. This may be because the given sign-in
provider is disabled for this Firebase project.
[ SMS unable to be sent until this region enabled by the app developer. ]
```

### 5b. Add your SHA-1 (and SHA-256) fingerprint — REQUIRED for Android

Phone Auth on Android will not send real SMS without this, even if the
provider is enabled in step 5a.

Get your debug SHA-1 (for local testing):
```bash
cd android
gradlew signingReport
```
Look for the `SHA1` and `SHA256` lines under the `debug` variant.

Or, if you don't have the project open, use keytool directly:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Then in Firebase Console:
1. Project Settings (gear icon, top left) → **General** tab
2. Scroll to **Your apps** → select your Android app
3. Click **Add fingerprint** → paste the SHA-1 → Save
4. Repeat for SHA-256 (recommended, some Play Integrity checks need it)
5. Re-download `google-services.json` after adding fingerprints and
   replace the one in `android/app/`

**Important:** the debug keystore fingerprint only works for local builds
signed with the debug key. Before you publish to Play Store, you must
also add the **release** keystore's SHA-1, or Phone Auth will break in
the release build even though it worked in debug.

### 5c. Test numbers — skip real SMS while developing

Avoid burning SMS quota (and avoid waiting on carrier delivery) by adding
fake test numbers that Firebase recognizes and auto-fills with a fixed OTP:

1. Authentication → Sign-in method → Phone → scroll down to
   **Phone numbers for testing (optional)**
2. Add a row, for example:
   - Phone number: `+1 123-456-7890`
   - Verification code: `123456`
3. Save

**Correct format:** Firebase expects the number in **E.164 format with a
space-separated display**, e.g. `+1 123-456-7890` for a US number, or
`+91 98765 43210` for an Indian number. Always include the country code
with `+`. Our app's `sendOtp()` already prefixes `+91` automatically if
no `+` is given — for testing with a `+1` US test number, type the full
number including `+1` into the phone field so the app doesn't double-prefix it.

When you enter a test number + its fixed OTP in the app, Firebase
recognizes it and **does not send a real SMS** — it just validates
against the code you configured. This works in the emulator and on
physical devices, with zero SMS cost.

### 5d. iOS — APNs setup (only if targeting iOS)

iOS Phone Auth needs APNs (push notifications) configured for silent
verification, or it falls back to a reCAPTCHA web view. If you're only
testing on Android for now, skip this and revisit before iOS release.

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

## Troubleshooting

### "This operation is not allowed" / "SMS unable to be sent until this region enabled"
You skipped Step 5a or 5b. Double-check the Phone provider is **Enabled**
(not just visible in the list) and that you've added at least one SHA-1
fingerprint matching the keystore your app is currently signed with.

### Testing with a non-Indian number (e.g. the US test number `+1 123-456-7890`)
Our `sendOtp()` in `chat_repository.dart` only auto-adds `+91` when the
phone field has **no** `+` prefix:
```dart
final e164 = phone.startsWith('+') ? phone : '+91$phone';
```
So to test with the US number `+1 123-456-7890`, you must type the full
`+11234567890` (digits only, with the `+`) into the phone field in the
app — not just `1234567890`, or it will incorrectly become `+911234567890`
and fail to match your configured test number.
If you want the UI's `+91` prefix label to be dynamic instead of hardcoded,
that's a small follow-up change to `phone_entry_screen.dart` — ask if you'd
like that.

### Real SMS still not arriving on a real number after SHA-1 is added
- Wait 5–10 minutes after adding the fingerprint — propagation isn't instant.
- Confirm you re-downloaded and replaced `google-services.json` after
  adding the fingerprint; the old file won't have the new app config.
- Check Firebase Console → Authentication → Usage tab for quota limits
  (free tier has a daily SMS cap).
- Some regions require Firebase's "SMS region policy" to be set to allow
  that country — Authentication → Settings → SMS region policy.

### `invalid-verification-code` even though you typed the right OTP
The `verificationId` may have expired (60s timeout in our `sendOtp` call)
or you're testing against a real number while a test number's fixed OTP
is configured for a *different* number. Re-tap "Send OTP" to get a fresh
`verificationId`.


## Done!

Run the app. On the Chat screen:
- Enter your name + phone number → Send OTP
- Enter the 6-digit OTP from SMS (or use your test number's fixed code)
- You land on the chat list
- Tap the pencil FAB → search for another user → start chatting
