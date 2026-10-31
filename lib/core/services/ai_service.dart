import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

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

/// Live Gemini first (SDK + HTTP fallback); demo answers only if API fails.
class AiService {
  GenerativeModel? _model;
  String? _activeModel;
  bool _liveVerified = false;

  bool get hasLiveModel {
    ensureModel();
    return AppConstants.geminiApiKey.isNotEmpty;
  }

  void ensureModel() {
    if (AppConstants.geminiApiKey.isEmpty) return;
    _activeModel ??= AppConstants.geminiModel;
    _model ??= GenerativeModel(
      model: _activeModel!,
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
    if (AppConstants.geminiApiKey.isEmpty) {
      return AiResult(
        text: DemoAiFallback.screenshot(language),
        isDemoFallback: true,
      );
    }
    try {
      final model = GenerativeModel(
        model: _activeModel ?? AppConstants.geminiModel,
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
      _liveVerified = true;
      return AiResult(text: text);
    } catch (e) {
      debugPrint('Screenshot AI failed: $e');
      final httpResult = await _generateViaHttp(
        prompt: '''
${_langPrefix(language)}
Explain this phone screenshot for a beginner. Cover: what screen, buttons, actions, cautions, next safe step.
''',
      );
      if (httpResult != null && httpResult.isNotEmpty) {
        return AiResult(text: httpResult);
      }
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
    if (AppConstants.geminiApiKey.isEmpty) {
      return AiResult(text: fallback(), isDemoFallback: true);
    }

    // Try SDK with model fallbacks.
    for (final modelName in AppConstants.geminiModelFallbacks) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: AppConstants.geminiApiKey,
          systemInstruction: Content.system(AppConstants.aiSystemPrompt),
        );
        final chat = model.startChat(history: history);
        final response = await chat.sendMessage(Content.text(prompt));
        final text = response.text?.trim();
        if (text != null && text.isNotEmpty) {
          _activeModel = modelName;
          _model = model;
          _liveVerified = true;
          return AiResult(text: text);
        }
      } catch (e) {
        debugPrint('Gemini SDK model $modelName failed: $e');
      }
    }

    // HTTP fallback for keys/models that reject the Dart SDK.
    final httpText = await _generateViaHttp(prompt: prompt);
    if (httpText != null && httpText.isNotEmpty) {
      _liveVerified = true;
      return AiResult(text: httpText);
    }

    return AiResult(
      text: fallback(),
      isDemoFallback: true,
      error: 'Gemini unavailable',
    );
  }

  Future<String?> _generateViaHttp({required String prompt}) async {
    final key = AppConstants.geminiApiKey;
    if (key.isEmpty) return null;

    for (final modelName in AppConstants.geminiModelFallbacks) {
      try {
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/'
          '$modelName:generateContent?key=$key',
        );
        final body = {
          'systemInstruction': {
            'parts': [
              {'text': AppConstants.aiSystemPrompt},
            ],
          },
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1024,
          },
        };
        final response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 60));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = decoded['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final content =
                candidates.first['content'] as Map<String, dynamic>?;
            final parts = content?['parts'] as List?;
            if (parts != null) {
              final buffer = StringBuffer();
              for (final part in parts) {
                if (part is Map && part['text'] is String) {
                  buffer.write(part['text']);
                }
              }
              final text = buffer.toString().trim();
              if (text.isNotEmpty) {
                _activeModel = modelName;
                return text;
              }
            }
          }
        } else if (response.statusCode == 503) {
          debugPrint('Gemini HTTP $modelName busy, trying next model');
        } else {
          debugPrint(
            'Gemini HTTP $modelName status ${response.statusCode}: ${response.body}',
          );
        }
      } catch (e) {
        debugPrint('Gemini HTTP $modelName failed: $e');
      }
    }
    return null;
  }

  String _langPrefix(AppLanguage language) {
    switch (language) {
      case AppLanguage.urdu:
        return 'IMPORTANT: Reply entirely in simple clear Urdu script (اردو).\n';
      case AppLanguage.romanUrdu:
        return 'IMPORTANT: Reply entirely in simple Roman Urdu (Urdu written with English letters).\n';
      case AppLanguage.english:
        return 'IMPORTANT: Reply in simple, clear English.\n';
    }
  }

  bool get isLiveVerified => _liveVerified;
}

abstract final class DemoAiFallback {
  static String technology(String question, AppLanguage language) {
    final q = question.toLowerCase();
    if (q.contains('whatsapp') || q.contains('واٹس') || q.contains('whats')) {
      return _wrap(
        language,
        introEn: 'Of course! Let us learn WhatsApp together.',
        introRu: 'Bilkul! Chalen WhatsApp mil kar seekhte hain.',
        introUr: 'بالکل! آئیے واٹس ایپ مل کر سیکھتے ہیں۔',
        whatEn:
            'WhatsApp is an app for sending messages and making calls using the internet.',
        whatRu:
            'WhatsApp internet se message aur call karne wala app hai.',
        whatUr:
            'واٹس ایپ انٹرنیٹ کے ذریعے پیغام اور کال کرنے والی ایپ ہے۔',
        stepsEn: const [
          'Open WhatsApp on your phone. Look for the green chat icon.',
          'Tap the green pencil or chat icon to start a new chat.',
          'Choose a contact, type your message, and tap the send arrow.',
        ],
        stepsRu: const [
          'Phone par WhatsApp kholen. Hara chat icon dhoondein.',
          'Naya chat shuru karne ke liye green pencil/chat icon dabayein.',
          'Contact chunein, message likhein, aur send arrow dabayein.',
        ],
        stepsUr: const [
          'فون پر واٹس ایپ کھولیں۔ سبز چیٹ آئیکن تلاش کریں۔',
          'نیا چیٹ شروع کرنے کے لیے سبز پنسل یا چیٹ آئیکن دبائیں۔',
          'رابطہ منتخب کریں، پیغام لکھیں، اور بھیجنے کا تیر دبائیں۔',
        ],
        safetyEn: 'Never share your WhatsApp code (OTP) with anyone.',
        safetyRu: 'Kabhi bhi WhatsApp OTP kisi ke sath share na karein.',
        safetyUr: 'واٹس ایپ کا کوڈ (OTP) کبھی کسی کے ساتھ شیئر نہ کریں۔',
      );
    }
    if (q.contains('video') || q.contains('ویڈیو')) {
      return _wrap(
        language,
        introEn: 'Happy to help you with video calls.',
        introRu: 'Video call mein madad karne mein khushi hogi.',
        introUr: 'ویڈیو کال میں مدد کر کے خوشی ہوگی۔',
        whatEn: 'A video call lets you see and talk to someone at the same time.',
        whatRu: 'Video call mein aap ek sath dekh aur baat kar sakte hain.',
        whatUr: 'ویڈیو کال میں آپ ایک ساتھ دیکھ اور بات کر سکتے ہیں۔',
        stepsEn: const [
          'Open WhatsApp and open a chat with the person.',
          'Tap the video camera icon at the top.',
          'Allow camera and microphone if asked, then wait for them to answer.',
        ],
        stepsRu: const [
          'WhatsApp kholen aur us shakhs ki chat kholen.',
          'Upar video camera icon dabayein.',
          'Agar poocha jaye to camera/mic allow karein, phir jawab ka wait karein.',
        ],
        stepsUr: const [
          'واٹس ایپ کھولیں اور اس شخص کی چیٹ کھولیں۔',
          'اوپر ویڈیو کیمرہ آئیکن دبائیں۔',
          'اگر پوچھا جائے تو کیمرہ/مائیک اجازت دیں، پھر جواب کا انتظار کریں۔',
        ],
        safetyEn: 'Only video call people you know and trust.',
        safetyRu: 'Sirf un logon se video call karein jinhein aap jante hain.',
        safetyUr: 'صرف ان لوگوں سے ویڈیو کال کریں جنہیں آپ جانتے اور بھروسہ کرتے ہیں۔',
      );
    }
    if (q.contains('wi-fi') ||
        q.contains('wifi') ||
        q.contains('وائی') ||
        q.contains('wi fi')) {
      return _wrap(
        language,
        introEn: 'Let us connect to Wi-Fi step by step.',
        introRu: 'Chalen Wi-Fi step by step connect karte hain.',
        introUr: 'آئیے وائی فائی قدم بہ قدم جوڑتے ہیں۔',
        whatEn: 'Wi-Fi is wireless internet at home or in a café.',
        whatRu: 'Wi-Fi ghar ya cafe ka wireless internet hai.',
        whatUr: 'وائی فائی گھر یا کیفے کا وائرلیس انٹرنیٹ ہے۔',
        stepsEn: const [
          'Open Settings on your phone.',
          'Tap Wi-Fi or Network & internet, then Wi-Fi.',
          'Turn Wi-Fi on, choose your network name, and enter the password.',
        ],
        stepsRu: const [
          'Phone ki Settings kholen.',
          'Wi-Fi ya Network & internet, phir Wi-Fi dabayein.',
          'Wi-Fi on karein, apna network chunein, password likhein.',
        ],
        stepsUr: const [
          'فون کی سیٹنگز کھولیں۔',
          'وائی فائی یا نیٹ ورک اینڈ انٹرنیٹ، پھر وائی فائی دبائیں۔',
          'وائی فائی آن کریں، اپنا نیٹ ورک منتخب کریں، پاس ورڈ لکھیں۔',
        ],
        safetyEn: 'Avoid unknown public Wi-Fi for banking.',
        safetyRu: 'Banking ke liye unknown public Wi-Fi use na karein.',
        safetyUr: 'بینکنگ کے لیے نامعلوم پبلک وائی فائی استعمال نہ کریں۔',
      );
    }
    if (q.contains('bank') || q.contains('بینک')) {
      return _wrap(
        language,
        introEn: 'Banking apps can feel scary at first. We will go slowly.',
        introRu: 'Banking apps pehle dara sakti hain. Hum dheere chalenge.',
        introUr: 'بینکنگ ایپس پہلے خوفناک لگ سکتی ہیں۔ ہم آہستہ چلیں گے۔',
        whatEn:
            'Online banking lets you check money and pay bills using your phone.',
        whatRu:
            'Online banking se aap phone par balance dekh aur bill bhar sakte hain.',
        whatUr:
            'آن لائن بینکنگ سے آپ فون پر رقم دیکھ اور بل ادا کر سکتے ہیں۔',
        stepsEn: const [
          'Only download your bank app from Google Play.',
          'Open the app and use the login your bank gave you.',
          'Look at Account Balance first — that shows how much money you have.',
        ],
        stepsRu: const [
          'Bank app sirf Google Play se download karein.',
          'App kholen aur bank wala login use karein.',
          'Pehle Account Balance dekhein — yeh batata hai kitni raqam hai.',
        ],
        stepsUr: const [
          'بینک ایپ صرف گوگل پلے سے ڈاؤن لوڈ کریں۔',
          'ایپ کھولیں اور بینک والا لاگ اِن استعمال کریں۔',
          'پہلے اکاؤنٹ بیلنس دیکھیں — یہ بتاتا ہے کتنی رقم ہے۔',
        ],
        safetyEn:
            'Never share OTP, PIN, or password. TechSaathi will never ask for them.',
        safetyRu:
            'OTP, PIN ya password kabhi share na karein. TechSathi kabhi nahi maangega.',
        safetyUr:
            'OTP، پن یا پاس ورڈ کبھی شیئر نہ کریں۔ ٹیک ساتھی کبھی نہیں مانگے گا۔',
      );
    }
    if (q.contains('photo') ||
        q.contains('picture') ||
        q.contains('تصویر') ||
        q.contains('image')) {
      return _wrap(
        language,
        introEn: 'Sending a photo is easy. Let us practise.',
        introRu: 'Photo bhejna asaan hai. Chalen mashq karte hain.',
        introUr: 'تصویر بھیجنا آسان ہے۔ آئیے مشق کرتے ہیں۔',
        whatEn: 'You can share a picture from your gallery in a chat.',
        whatRu: 'Aap gallery se chat mein tasveer share kar sakte hain.',
        whatUr: 'آپ گیلری سے چیٹ میں تصویر شیئر کر سکتے ہیں۔',
        stepsEn: const [
          'Open the chat where you want to send the photo.',
          'Tap the attachment (paperclip or +) icon.',
          'Choose Gallery, select the photo, then tap Send.',
        ],
        stepsRu: const [
          'Woh chat kholen jahan photo bhejni hai.',
          'Attachment (paperclip ya +) icon dabayein.',
          'Gallery chunein, photo select karein, Send dabayein.',
        ],
        stepsUr: const [
          'وہ چیٹ کھولیں جہاں تصویر بھیجنی ہے۔',
          'اٹیچمنٹ (پیپر کلپ یا +) آئیکن دبائیں۔',
          'گیلری منتخب کریں، تصویر چنیں، پھر بھیجیں دبائیں۔',
        ],
        safetyEn: 'Do not send photos of ID cards, bank cards, or OTPs.',
        safetyRu: 'ID card, bank card ya OTP ki photos na bhejein.',
        safetyUr: 'شناختی کارڈ، بینک کارڈ یا OTP کی تصاویر نہ بھیجیں۔',
      );
    }
    if (q.contains('scam') || q.contains('fraud') || q.contains('دھوکہ')) {
      return _wrap(
        language,
        introEn: 'Good question — staying safe is important.',
        introRu: 'Achha sawal — mehfooz rehna zaroori hai.',
        introUr: 'اچھا سوال — محفوظ رہنا ضروری ہے۔',
        whatEn:
            'A scam is when someone tries to trick you to steal money or information.',
        whatRu:
            'Scam woh hai jab koi aap ko dhoka de kar paise ya maloomat churana chahe.',
        whatUr:
            'دھوکہ وہ ہے جب کوئی آپ کو فریب دے کر پیسے یا معلومات چرانا چاہے۔',
        stepsEn: const [
          'Be careful if a message says “urgent” or “you won a prize”.',
          'Never share OTP, PIN, or password — even if they sound official.',
          'Call your bank using the number on your debit card, not from the message.',
        ],
        stepsRu: const [
          'Agar message “urgent” ya “prize jeet gaye” kahe to hoshiyar rahein.',
          'OTP, PIN ya password kabhi share na karein — chahe official lage.',
          'Bank ko debit card par likhe number se call karein, message wale se nahi.',
        ],
        stepsUr: const [
          'اگر پیغام کہے “فوری” یا “آپ نے انعام جیتا” تو ہوشیار رہیں۔',
          'OTP، پن یا پاس ورڈ کبھی شیئر نہ کریں — چاہے سرکاری لگے۔',
          'بینک کو ڈیبٹ کارڈ پر لکھے نمبر سے کال کریں، پیغام والے سے نہیں۔',
        ],
        safetyEn:
            'If unsure, stop and ask a trusted family member before tapping any link.',
        safetyRu:
            'Agar shak ho to ruk jayein aur link dabane se pehle bharose wale se poochhein.',
        safetyUr:
            'اگر شک ہو تو رک جائیں اور کوئی لنک دبانے سے پہلے بھروسہ مند سے پوچھیں۔',
      );
    }
    return _wrap(
      language,
      introEn: 'I am here with you. Let us learn this together.',
      introRu: 'Main aap ke sath hoon. Chalen yeh mil kar seekhte hain.',
      introUr: 'میں آپ کے ساتھ ہوں۔ آئیے یہ مل کر سیکھتے ہیں۔',
      whatEn: 'We will break your question into small, clear steps.',
      whatRu: 'Hum aap ke sawal ko chhote clear steps mein todoonge.',
      whatUr: 'ہم آپ کے سوال کو چھوٹے واضح قدموں میں توڑیں گے۔',
      stepsEn: const [
        'Tell me which app or screen you are looking at.',
        'We will name each important button in simple words.',
        'Then you can try the steps yourself while I wait patiently.',
      ],
      stepsRu: const [
        'Batayein aap kaun si app ya screen dekh rahe hain.',
        'Hum har zaroori button simple words mein naam denge.',
        'Phir aap khud steps try karein — main sabr se wait karunga.',
      ],
      stepsUr: const [
        'بتائیں آپ کون سی ایپ یا اسکرین دیکھ رہے ہیں۔',
        'ہم ہر ضروری بٹن کا سادہ نام بتائیں گے۔',
        'پھر آپ خود قدم آزمائیں — میں صبر سے انتظار کروں گا۔',
      ],
      safetyEn: 'Take your time. There is no rush.',
      safetyRu: 'Apna time lein. Koi jaldi nahi.',
      safetyUr: 'اپنا وقت لیں۔ کوئی جلدی نہیں۔',
    );
  }

  static String banking(String concept, AppLanguage language) {
    return technology('banking $concept', language);
  }

  static String screenshot(AppLanguage language) {
    return _wrap(
      language,
      introEn: 'Thank you for sharing a screenshot.',
      introRu: 'Screenshot share karne ka shukriya.',
      introUr: 'اسکرین شاٹ شیئر کرنے کا شکریہ۔',
      whatEn: 'This looks like a phone screen with buttons and text fields.',
      whatRu: 'Yeh phone screen lagti hai jisme buttons aur text fields hain.',
      whatUr: 'یہ فون اسکرین لگتی ہے جس میں بٹن اور لکھنے کی جگہیں ہیں۔',
      stepsEn: const [
        'Look at the top title — it usually tells you where you are.',
        'Large buttons in the middle are often the main actions.',
        'If you see a warning in red or orange, pause and read it carefully.',
      ],
      stepsRu: const [
        'Upar title dekhein — yeh batata hai aap kahan hain.',
        'Beech ke bade buttons aksar asl kaam hote hain.',
        'Agar laal/orange warning dikhe to ruk kar carefully parhein.',
      ],
      stepsUr: const [
        'اوپر کا عنوان دیکھیں — یہ بتاتا ہے آپ کہاں ہیں۔',
        'درمیان کے بڑے بٹن اکثر اصل کام ہوتے ہیں۔',
        'اگر سرخ/نارنجی وارننگ دکھے تو رک کر غور سے پڑھیں۔',
      ],
      safetyEn:
          'Hide passwords, OTPs, PINs and account numbers before sharing screenshots.',
      safetyRu:
          'Screenshot se pehle password, OTP, PIN aur account number chhupa lein.',
      safetyUr:
          'اسکرین شاٹ سے پہلے پاس ورڈ، OTP، پن اور اکاؤنٹ نمبر چھپا لیں۔',
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
    if (lower.contains('http') ||
        lower.contains('bit.ly') ||
        lower.contains('www.')) {
      signals.add('Contains a link');
    }
    if (lower.contains('urgent') ||
        lower.contains('immediately') ||
        lower.contains('suspend') ||
        lower.contains('blocked') ||
        lower.contains('فوری')) {
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

    final level = signals.length >= 3
        ? 'High risk'
        : signals.isNotEmpty
            ? 'Suspicious'
            : 'Low indicators';
    final signs = signals.isEmpty
        ? 'No strong scam patterns found — still verify important messages yourself.'
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
          'options': [
            'Your favourite colour',
            'Your OTP or PIN',
            'The app name',
          ],
          'answerIndex': 1,
          'explanation':
              'OTP and PIN are secret. Real staff will never ask for them in a message.',
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
    required String introEn,
    required String introRu,
    required String introUr,
    required String whatEn,
    required String whatRu,
    required String whatUr,
    required List<String> stepsEn,
    required List<String> stepsRu,
    required List<String> stepsUr,
    required String safetyEn,
    required String safetyRu,
    required String safetyUr,
  }) {
    switch (language) {
      case AppLanguage.english:
        final steps = [
          for (var i = 0; i < stepsEn.length; i++)
            'Step ${i + 1}. ${stepsEn[i]}',
        ].join('\n');
        return '''
$introEn

What we are going to do:
$whatEn

$steps

Important safety advice:
$safetyEn

Would you like to practise this yourself?
''';
      case AppLanguage.romanUrdu:
        final steps = [
          for (var i = 0; i < stepsRu.length; i++)
            'Step ${i + 1}. ${stepsRu[i]}',
        ].join('\n');
        return '''
$introRu

Hum yeh seekhne wale hain:
$whatRu

$steps

Zaroori hifazati mashwara:
$safetyRu

Kya aap khud practice karna chahenge?
''';
      case AppLanguage.urdu:
        final steps = [
          for (var i = 0; i < stepsUr.length; i++)
            'قدم ${i + 1}. ${stepsUr[i]}',
        ].join('\n');
        return '''
$introUr

ہم یہ سیکھنے والے ہیں:
$whatUr

$steps

اہم حفاظتی مشورہ:
$safetyUr

کیا آپ خود مشق کرنا چاہیں گے؟
''';
    }
  }
}
