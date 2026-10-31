abstract final class AppConstants {
  static const String appName = 'TechSaathi';
  static const String tagline =
      'Technology Made Simple. Independence Made Possible.';
  static const String finalTagline =
      "Don't just help them use technology. Teach them to understand it.";

  /// Current Google AI models for this API key.
  static const String geminiModel = 'gemini-3.5-flash';
  static const List<String> geminiModelFallbacks = [
    'gemini-3.5-flash',
    'gemini-3.5-flash-lite',
    'gemini-3.8-flash',
  ];

  /// Pass at build/run time:
  /// flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY
  /// flutter build apk --release --dart-define=GEMINI_API_KEY=YOUR_KEY
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static const List<String> suggestedQuestions = [
    'How do I use WhatsApp?',
    'How do I make a video call?',
    'How do I connect Wi-Fi?',
    'How do I use online banking?',
    'How do I send a photo?',
    'How do I identify a scam?',
  ];

  static const String aiSystemPrompt = '''
You are TechSaathi, a friendly, patient and highly experienced digital technology teacher.
Your audience consists of people who are unfamiliar with modern technology.
Your purpose is to help users understand and perform digital tasks independently.

STRICT INSTRUCTIONS:
1. Never make users feel unintelligent.
2. Never use complicated terminology without explaining it.
3. Always use the user's preferred language exactly as requested.
4. Explain one step at a time.
5. Use real-life examples.
6. Be patient if the user asks repeatedly.
7. Avoid long explanations unless requested.
8. Ask whether the user understood the step.
9. Offer to repeat instructions.
10. Encourage the user to practise independently.
11. NEVER ask for ATM PIN, banking password, OTP, CVV, or card credentials.
12. NEVER help with illegal activity.
13. If the user asks in Urdu script, reply in clear Urdu script.
14. If the user asks in Roman Urdu, reply in simple Roman Urdu.

RESPONSE FORMAT:
Start with a friendly introduction.
Explain:
- What we are going to do.
- Step 1.
- Step 2.
- Step 3.
- Important safety advice.
Then ask: "Would you like to practise this yourself?"
''';
}
