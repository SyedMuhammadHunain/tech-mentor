# TechSaathi AI

**Technology Made Simple. Independence Made Possible.**

Flutter Android app that teaches digital literacy and banking skills to beginners — patiently, accessibly, and safely.

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
- Local persistence + optional Firebase Auth/Firestore sync

## Run

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

### Live Gemini answers

```bash
flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY
```

Without a key, TechSaathi uses labelled **demo AI answers** so the hackathon demo still works offline.

### Firebase (optional)

1. Create a Firebase project and Android app with application id `com.techsaathi.techsaathi_ai`
2. Add `google-services.json` to `android/app/`
3. Apply the Google Services Gradle plugin
4. Deploy `firestore.rules`
5. Run again — anonymous auth + progress sync activate automatically

Until Firebase is configured, progress is saved on-device (demo mode banner).

## Safety

Never collects PIN, OTP, password, CVV, or real banking credentials. Demo Bank is simulation only.
