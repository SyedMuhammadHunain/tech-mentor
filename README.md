# TechSaathi AI

**Technology Made Simple. Independence Made Possible.**

Flutter Android app that teaches digital literacy and banking skills to beginners.

## Features

- Onboarding (language, experience, learning style)
- Home dashboard with four primary modules
- AI Teacher (Gemini + offline demo fallback, voice in/out)
- Banking Saathi (14 beginner lessons + quizzes)
- TechSaathi Demo Bank (simulated transfers — no real money)
- Explain My Screen (screenshot helper)
- ScamShield (message risk analysis)
- Learn tab + My Progress with independence tracking
- Profile / accessibility settings
- Local progress on device; optional Firestore sync **without login**

There is **no Firebase Authentication**.

## Run

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Live Gemini is enabled in the app. To override the key:

```bash
flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY
```

## Firebase (no login)

Cloud sync uses a local device id, not user accounts.

1. Add an Android app with application id `com.techsaathi.techsaathi_ai`
2. Place `google-services.json` in `android/app/`
3. Apply the Google Services Gradle plugin
4. Deploy `firestore.rules`

Until Firebase is connected, progress stays on the device.

## Safety

Never collects PIN, OTP, password, CVV, or real banking credentials. Demo Bank is simulation only.
