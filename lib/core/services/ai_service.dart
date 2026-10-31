import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../constants/app_constants.dart';
import '../../data/models/user_preferences.dart';

class AiResult {
  const AiResult({
    required this.text,
    this.isDemoFallback = false,
    this.error,
  });

  final String text;
  final bool isDemoFallback;
  final String? error;

  bool get hasError => error != null;
}

/// Gemini via API key when available; otherwise friendly local demo answers.
class AiService {
  GenerativeModel? _model;

  bool get hasLiveModel =>
      AppConstants.geminiApiKey.isNotEmpty && _model != null;

  void ensureModel() {
    if (AppConstants.geminiApiKey.isEmpty) return;
    _model ??= GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: AppConstants.geminiApiKey,
      systemInstruction: Content.system(AppConstants.aiSystemPrompt),
    );
  }

  Future<AiResult> askTechnologyQuestion({
    required String question,
    required AppLanguage language,
    List<Content>? history,
  }) async {
    return _generate(
      prompt: _langPrefix(language) + question,
      history: history,
      fallback: () => DemoAiFallback.technology(question, language),
    );
  }

  Future<AiResult> explainBankingConcept({
    required String concept,
    required AppLanguage language,
  }) async {
    return _generate(
      prompt: '''
${_langPrefix(language)}
Explain this banking concept for absolute beginners: $concept
Never ask for PIN, OTP, password, CVV, or real account details.
''',
      fallback: () => DemoAiFallback.banking(concept, language),
    );
  }

  Future<AiResult> explainScreenshot({
    required Uint8List imageBytes,
    required AppLanguage language,
    String? mimeType,
  }) async {
    ensureModel();
    if (!hasLiveModel) {
      return AiResult(
        text: DemoAiFallback.screenshot(language),
        isDemoFallback: true,
      );
    }
    try {
      final model = GenerativeModel(
        model: AppConstants.geminiModel,
        apiKey: AppConstants.geminiApiKey,
        systemInstruction: Content.system(AppConstants.aiSystemPrompt),
      );
      final response = await model.generateContent([
        Content.multi([
          TextPart('''
${_langPrefix(language)}
A beginner uploaded a phone screenshot. Explain it safely.
Format:
1. What is this screen?
2. What do the important buttons mean?
3. What can you do here?
4. What should you be careful about?
5. What is the next safe step?
Never ask for passwords, OTPs, PINs, or account numbers.
'''),
          DataPart(mimeType ?? 'image/jpeg', imageBytes),
        ]),
      ]);
      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        return AiResult(
          text: DemoAiFallback.screenshot(language),
          isDemoFallback: true,
          error: 'Empty AI response',
        );
      }
      return AiResult(text: text);
    } catch (e) {
      debugPrint('Screenshot AI failed: $e');
      return AiResult(
        text: DemoAiFallback.screenshot(language),
        isDemoFallback: true,
        error: e.toString(),
      );
    }
  }

  Future<AiResult> analyzeSuspiciousMessage({
    required String message,
    required AppLanguage language,
  }) async {
    return _generate(
      prompt: '''
${_langPrefix(language)}
Analyze this message for scam risk. Message:
---
$message
---
Return a clear beginner-friendly report with:
- Potential risk level (Low indicators / Suspicious / High risk)
- Warning signs
- Simple explanation
- Recommended action
Never say a message is guaranteed safe.
Never open or recommend opening suspicious links.
''',
      fallback: () => DemoAiFallback.scam(message, language),
    );
  }

  Future<AiResult> generateQuiz({
    required String topic,
    required AppLanguage language,
  }) async {
    return _generate(
      prompt: '''
${_langPrefix(language)}
Create 3 simple multiple-choice quiz questions about: $topic
Format as JSON array: [{"question":"...","options":["a","b","c"],"answerIndex":0,"explanation":"..."}]
''',
      fallback: () => jsonEncode(DemoAiFallback.quiz(topic)),
    );
  }

  Future<AiResult> simplifyExplanation({
    required String text,
    required AppLanguage language,
  }) async {
    return _generate(
      prompt: '''
${_langPrefix(language)}
Simplify this explanation for a complete beginner. Keep it short:
$text
''',
      fallback: () => text,
    );
  }

  Future<AiResult> _generate({
    required String prompt,
    required String Function() fallback,
    List<Content>? history,
  }) async {
    ensureModel();
    if (!hasLiveModel) {
      return AiResult(text: fallback(), isDemoFallback: true);
    }
    try {
      final chat = _model!.startChat(history: history);
      final response = await chat.sendMessage(Content.text(prompt));
      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        return AiResult(
          text: fallback(),
          isDemoFallback: true,
          error: 'Empty response',
        );
      }
      return AiResult(text: text);
    } catch (e) {
      debugPrint('AI error: $e');
      return AiResult(
        text: fallback(),
        isDemoFallback: true,
        error: e.toString(),
      );
    }
  }

  String _langPrefix(AppLanguage language) {
    switch (language) {
      case AppLanguage.urdu:
        return 'Reply entirely in simple Urdu (اردو).\n';
      case AppLanguage.romanUrdu:
        return 'Reply entirely in simple Roman Urdu.\n';
      case AppLanguage.english:
        return 'Reply in simple, clear English.\n';
    }
  }
}

abstract final class DemoAiFallback {
  static String technology(String question, AppLanguage language) {
    final q = question.toLowerCase();
    if (q.contains('whatsapp')) {
      return _wrap(
        language,
        intro: 'Of course! Let us learn WhatsApp together.',
        what: 'WhatsApp is an app for sending messages and making calls using the internet.',
        steps: [
          'Open WhatsApp on your phone. Look for the green chat icon.',
          'Tap the green pencil or chat icon to start a new chat.',
          'Choose a contact, type your message, and tap the send arrow.',
        ],
        safety: 'Never share your WhatsApp code (OTP) with anyone.',
      );
    }
    if (q.contains('video call') || q.contains('video')) {
      return _wrap(
        language,
        intro: 'Happy to help you with video calls.',
        what: 'A video call lets you see and talk to someone at the same time.',
        steps: [
          'Open WhatsApp and open a chat with the person.',
          'Tap the video camera icon at the top.',
          'Allow camera and microphone if asked, then wait for them to answer.',
        ],
        safety: 'Only video call people you know and trust.',
      );
    }
    if (q.contains('wi-fi') || q.contains('wifi') || q.contains('wi fi')) {
      return _wrap(
        language,
        intro: 'Let us connect to Wi-Fi step by step.',
        what: 'Wi-Fi is wireless internet at home or in a café.',
        steps: [
          'Open Settings on your phone.',
          'Tap Wi-Fi or Network & internet, then Wi-Fi.',
          'Turn Wi-Fi on, choose your network name, and enter the password.',
        ],
        safety: 'Avoid unknown public Wi-Fi for banking.',
      );
    }
    if (q.contains('bank') || q.contains('banking')) {
      return _wrap(
        language,
        intro: 'Banking apps can feel scary at first. We will go slowly.',
        what: 'Online banking lets you check money and pay bills using your phone.',
        steps: [
          'Only download your bank app from Google Play.',
          'Open the app and use the login your bank gave you.',
          'Look at Account Balance first — that shows how much money you have.',
        ],
        safety: 'Never share OTP, PIN, or password. TechSaathi will never ask for them.',
      );
    }
    if (q.contains('photo') || q.contains('picture') || q.contains('image')) {
      return _wrap(
        language,
        intro: 'Sending a photo is easy. Let us practise.',
        what: 'You can share a picture from your gallery in a chat.',
        steps: [
          'Open the chat where you want to send the photo.',
          'Tap the attachment (paperclip or +) icon.',
          'Choose Gallery, select the photo, then tap Send.',
        ],
        safety: 'Do not send photos of ID cards, bank cards, or OTPs.',
      );
    }
    if (q.contains('scam') || q.contains('fraud')) {
      return _wrap(
        language,
        intro: 'Good question — staying safe is important.',
        what: 'A scam is when someone tries to trick you to steal money or information.',
        steps: [
          'Be careful if a message says “urgent” or “you won a prize”.',
          'Never share OTP, PIN, or password — even if they sound official.',
          'Call your bank using the number on your debit card, not from the message.',
        ],
        safety: 'If unsure, stop and ask a trusted family member before tapping any link.',
      );
    }
    return _wrap(
      language,
      intro: 'I am here with you. Let us learn this together.',
      what: 'We will break your question into small, clear steps.',
      steps: [
        'Tell me which app or screen you are looking at.',
        'We will name each important button in simple words.',
        'Then you can try the steps yourself while I wait patiently.',
      ],
      safety: 'Take your time. There is no rush.',
    );
  }

  static String banking(String concept, AppLanguage language) {
    return _wrap(
      language,
      intro: 'Let us understand this banking idea calmly.',
      what: concept.trim().isEmpty
          ? 'Banking features help you manage money on your phone.'
          : '“$concept” is a banking idea we can learn with a simple example.',
      steps: [
        'First, remember: this is only learning — no real money moves here.',
        'We will learn what the word means and why people use it.',
        'Then you can practise in TechSaathi Demo Bank.',
      ],
      safety: 'Never share PIN, OTP, password, or CVV with anyone.',
    );
  }

  static String screenshot(AppLanguage language) {
    return _wrap(
      language,
      intro: 'Thank you for sharing a screenshot. (Demo explanation mode)',
      what: 'This looks like a phone screen with buttons and text fields.',
      steps: [
        'Look at the top title — it usually tells you where you are.',
        'Large buttons in the middle are often the main actions.',
        'If you see a warning in red or orange, pause and read it carefully.',
      ],
      safety:
          'Hide passwords, OTPs, PINs and account numbers before sharing screenshots. Connect a Gemini API key for live image analysis.',
    );
  }

  static String scam(String message, AppLanguage language) {
    final lower = message.toLowerCase();
    final signals = <String>[];
    if (lower.contains('otp') ||
        lower.contains('pin') ||
        lower.contains('password') ||
        lower.contains('cvv')) {
      signals.add('Asks for secret codes (OTP / PIN / password)');
    }
    if (lower.contains('http') || lower.contains('bit.ly') || lower.contains('www.')) {
      signals.add('Contains a link');
    }
    if (lower.contains('urgent') ||
        lower.contains('immediately') ||
        lower.contains('suspend') ||
        lower.contains('blocked')) {
      signals.add('Uses urgency or fear');
    }
    if (lower.contains('prize') ||
        lower.contains('won') ||
        lower.contains('lottery') ||
        lower.contains('gift')) {
      signals.add('Promises a prize or gift');
    }
    if (lower.contains('bank') ||
        lower.contains('jazzcash') ||
        lower.contains('easypaisa') ||
        lower.contains('nadra')) {
      signals.add('Mentions a trusted organisation');
    }

    String level;
    if (signals.length >= 3) {
      level = 'High risk';
    } else if (signals.isNotEmpty) {
      level = 'Suspicious';
    } else {
      level = 'Low indicators';
    }

    final signs = signals.isEmpty
        ? 'No strong scam patterns found in this short text — still verify important messages yourself.'
        : signals.map((s) => '• $s').join('\n');

    switch (language) {
      case AppLanguage.urdu:
        return '''
ممکنہ خطرے کی سطح: $level

انتباہی علامات:
$signs

سادہ وضاحت:
دھوکہ باز اکثر جلدی پیدا کرتے ہیں اور رازدارانہ معلومات مانگتے ہیں۔

تجویز کردہ اقدام:
لنک نہ کھولیں۔ اگر پیغام بینک کے بارے میں ہے تو کارڈ پر لکھا نمبر استعمال کر کے خود تصدیق کریں۔
کوئی پیغام مکمل طور پر محفوظ ہونے کی ضمانت نہیں۔
''';
      case AppLanguage.romanUrdu:
        return '''
Potential risk level: $level

Warning signs:
$signs

Simple explanation:
Scammers aksar jaldi aur darr ka use karte hain, aur OTP ya password mangte hain.

Recommended action:
Suspicious link mat kholen. Bank ke bare mein message ho to card par likha number use karke khud verify karein.
Koi message guaranteed safe nahi hota.
''';
      case AppLanguage.english:
        return '''
Potential risk level: $level

Warning signs:
$signs

Simple explanation:
Scammers often create urgency and ask for secret information.

Recommended action:
Do not open suspicious links. If the message claims to be from your bank, verify using the phone number printed on your card.
We never claim a message is guaranteed safe.
''';
    }
  }

  static List<Map<String, dynamic>> quiz(String topic) => [
        {
          'question': 'What should you never share with anyone?',
          'options': ['Your favourite colour', 'Your OTP or PIN', 'The app name'],
          'answerIndex': 1,
          'explanation': 'OTP and PIN are secret. Real staff will never ask for them in a message.',
        },
        {
          'question': 'TechSaathi Demo Bank moves real money. True or false?',
          'options': ['True', 'False', 'Only sometimes'],
          'answerIndex': 1,
          'explanation': 'It is a simulation only — no real money.',
        },
        {
          'question': 'Best way to learn a new phone skill?',
          'options': [
            'Let someone else always do it for you',
            'Practise the steps yourself',
            'Ignore the instructions',
          ],
          'answerIndex': 1,
          'explanation': 'Practising yourself builds independence.',
        },
      ];

  static String _wrap(
    AppLanguage language, {
    required String intro,
    required String what,
    required List<String> steps,
    required String safety,
  }) {
    final stepText = [
      for (var i = 0; i < steps.length; i++) 'Step ${i + 1}. ${steps[i]}'
    ].join('\n');

    switch (language) {
      case AppLanguage.english:
        return '''
$intro

What we are going to do:
$what

$stepText

Important safety advice:
$safety

Would you like to practise this yourself?
''';
      case AppLanguage.romanUrdu:
        return '''
$intro

Hum yeh seekhne wale hain:
$what

$stepText

Zaroori hifazati mashwara:
$safety

Kya aap khud practice karna chahenge?
''';
      case AppLanguage.urdu:
        return '''
$intro

ہم یہ سیکھنے والے ہیں:
$what

$stepText

اہم حفاظتی مشورہ:
$safety

کیا آپ خود مشق کرنا چاہیں گے؟
''';
    }
  }
}
