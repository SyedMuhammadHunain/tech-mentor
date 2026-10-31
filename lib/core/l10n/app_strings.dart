import '../../data/models/user_preferences.dart';

/// Dynamic UI copy for English, Urdu, and Roman Urdu.
class AppStrings {
  AppStrings(this.language);

  final AppLanguage language;

  bool get isRtl => language.isRtl;

  String get appName => 'TechSathi';

  String get tagline {
    switch (language) {
      case AppLanguage.urdu:
        return 'ٹیکنالوجی آسان، آزادی ممکن';
      case AppLanguage.romanUrdu:
        return 'Technology asaan. Azadi mumkin.';
      case AppLanguage.english:
        return 'Technology Made Simple. Independence Made Possible.';
    }
  }

  String greeting(String name) {
    final who = name.trim().isEmpty ? '' : ' $name';
    switch (language) {
      case AppLanguage.urdu:
        return 'السلام علیکم!$who';
      case AppLanguage.romanUrdu:
        return 'Assalam-o-Alaikum!$who';
      case AppLanguage.english:
        return 'Assalam-o-Alaikum!$who';
    }
  }

  String get howCanIHelp {
    switch (language) {
      case AppLanguage.urdu:
        return 'آج میں آپ کی کیسے مدد کر سکتا ہوں؟';
      case AppLanguage.romanUrdu:
        return 'Aaj main aap ki kaise madad kar sakta hoon?';
      case AppLanguage.english:
        return 'How can I help you today?';
    }
  }

  String get askVoiceOrType {
    switch (language) {
      case AppLanguage.urdu:
        return 'آواز سے پوچھیں یا سوال لکھیں۔';
      case AppLanguage.romanUrdu:
        return 'Awaz se poochhein ya sawal likhein.';
      case AppLanguage.english:
        return 'Ask with your voice or type a question.';
    }
  }

  String get voice => language == AppLanguage.urdu
      ? 'آواز'
      : language == AppLanguage.romanUrdu
          ? 'Awaz'
          : 'Voice';

  String get type => language == AppLanguage.urdu
      ? 'لکھیں'
      : language == AppLanguage.romanUrdu
          ? 'Likhein'
          : 'Type';

  String get learnWith => language == AppLanguage.urdu
      ? 'ٹیک ساتھی کے ساتھ سیکھیں'
      : language == AppLanguage.romanUrdu
          ? 'TechSathi ke sath seekhein'
          : 'Learn with TechSathi';

  String get aiTeacher => language == AppLanguage.urdu
      ? 'اے آئی استاد'
      : language == AppLanguage.romanUrdu
          ? 'AI Teacher'
          : 'AI Teacher';

  String get aiTeacherDesc => language == AppLanguage.urdu
      ? 'ٹیکنالوجی کے بارے میں کچھ بھی پوچھیں۔'
      : language == AppLanguage.romanUrdu
          ? 'Technology ke bare mein kuch bhi poochhein.'
          : 'Ask anything about technology.';

  String get bankingSaathi => language == AppLanguage.urdu
      ? 'بینکنگ ساتھی'
      : 'Banking Saathi';

  String get bankingSaathiDesc => language == AppLanguage.urdu
      ? 'بینکنگ ایپس محفوظ طریقے سے سیکھیں۔'
      : language == AppLanguage.romanUrdu
          ? 'Banking apps mehfooz tareeqe se seekhein.'
          : 'Learn to use banking applications safely.';

  String get scamShield => language == AppLanguage.urdu
      ? 'اسکیم شیلڈ'
      : 'ScamShield';

  String get scamShieldDesc => language == AppLanguage.urdu
      ? 'آن لائن دھوکہ پہچاننا سیکھیں۔'
      : language == AppLanguage.romanUrdu
          ? 'Online dhoka pehchanna seekhein.'
          : 'Learn to recognize online scams.';

  String get explainScreen => language == AppLanguage.urdu
      ? 'میری اسکرین سمجھاؤ'
      : language == AppLanguage.romanUrdu
          ? 'Meri screen samjhao'
          : 'Explain My Screen';

  String get explainScreenDesc => language == AppLanguage.urdu
      ? 'الجھی ہوئی فون اسکرین سمجھیں۔'
      : language == AppLanguage.romanUrdu
          ? 'Uljhi hui phone screen samjhein.'
          : 'Understand confusing phone screens.';

  String get continueLearning => language == AppLanguage.urdu
      ? 'سیکھنا جاری رکھیں'
      : language == AppLanguage.romanUrdu
          ? 'Seekhna jari rakhein'
          : 'Continue Learning';

  String get yourProgress => language == AppLanguage.urdu
      ? 'آپ کی پیش رفت'
      : language == AppLanguage.romanUrdu
          ? 'Aap ki peshraft'
          : 'Your Learning Progress';

  String lessonsCompleted(int n) {
    switch (language) {
      case AppLanguage.urdu:
        return '$n اسباق مکمل';
      case AppLanguage.romanUrdu:
        return '$n lessons mukammal';
      case AppLanguage.english:
        return '$n lessons completed';
    }
  }

  String streak(int n) {
    switch (language) {
      case AppLanguage.urdu:
        return 'سلسلہ: $n دن';
      case AppLanguage.romanUrdu:
        return 'Streak: $n din';
      case AppLanguage.english:
        return 'Streak: $n day${n == 1 ? '' : 's'}';
    }
  }

  String get home => language == AppLanguage.urdu
      ? 'ہوم'
      : language == AppLanguage.romanUrdu
          ? 'Home'
          : 'Home';

  String get learn => language == AppLanguage.urdu
      ? 'سیکھیں'
      : language == AppLanguage.romanUrdu
          ? 'Seekhein'
          : 'Learn';

  String get practice => language == AppLanguage.urdu
      ? 'مشق'
      : language == AppLanguage.romanUrdu
          ? 'Mashq'
          : 'Practice';

  String get myProgress => language == AppLanguage.urdu
      ? 'میری پیش رفت'
      : language == AppLanguage.romanUrdu
          ? 'Meri peshraft'
          : 'My Progress';

  String get profile => language == AppLanguage.urdu
      ? 'پروفائل اور ترتیبات'
      : language == AppLanguage.romanUrdu
          ? 'Profile aur settings'
          : 'Profile & Settings';

  String get thinking => language == AppLanguage.urdu
      ? 'ٹیک ساتھی سوچ رہا ہے…'
      : language == AppLanguage.romanUrdu
          ? 'TechSathi soch raha hai…'
          : 'TechSaathi is thinking…';

  String get typeQuestion => language == AppLanguage.urdu
      ? 'اپنا سوال لکھیں…'
      : language == AppLanguage.romanUrdu
          ? 'Apna sawal likhein…'
          : 'Type your question…';

  String get welcomeTitle => language == AppLanguage.urdu
      ? 'ٹیک ساتھی میں خوش آمدید!'
      : language == AppLanguage.romanUrdu
          ? 'TechSathi mein khush aamdeed!'
          : 'Welcome to TechSaathi!';

  String get welcomeDesc => language == AppLanguage.urdu
      ? 'ٹیکنالوجی سمجھنے کا آپ کا دوستانہ رہنما۔'
      : language == AppLanguage.romanUrdu
          ? 'Technology samajhne ka aap ka dostana rehnuma.'
          : 'Your friendly guide to understanding technology.';

  String get getStarted => language == AppLanguage.urdu
      ? 'شروع کریں'
      : language == AppLanguage.romanUrdu
          ? 'Shuru karein'
          : 'Get Started';

  String get continueLabel => language == AppLanguage.urdu
      ? 'آگے بڑھیں'
      : language == AppLanguage.romanUrdu
          ? 'Aage barhein'
          : 'Continue';

  String get startLearning => language == AppLanguage.urdu
      ? 'سیکھنا شروع کریں'
      : language == AppLanguage.romanUrdu
          ? 'Seekhna shuru karein'
          : 'Start Learning';

  String get preferredLanguage => language == AppLanguage.urdu
      ? 'آپ کون سی زبان پسند کرتے ہیں؟'
      : language == AppLanguage.romanUrdu
          ? 'Aap konsi zaban pasand karte hain?'
          : 'Which language do you prefer?';

  String get comfortQuestion => language == AppLanguage.urdu
      ? 'آپ ٹیکنالوجی کے ساتھ کتنے پراعتماد ہیں؟'
      : language == AppLanguage.romanUrdu
          ? 'Aap technology ke sath kitne confident hain?'
          : 'How comfortable are you with technology?';

  String get teachingStyle => language == AppLanguage.urdu
      ? 'آپ کیسے سیکھنا چاہتے ہیں؟'
      : language == AppLanguage.romanUrdu
          ? 'Aap kaise seekhna chahte hain?'
          : 'How would you like us to teach you?';

  String get letsLearn => language == AppLanguage.urdu
      ? 'آئیے کچھ نیا سیکھتے ہیں!'
      : language == AppLanguage.romanUrdu
          ? 'Aiye kuch naya seekhte hain!'
          : "Let's learn something new!";

  String get yourName => language == AppLanguage.urdu
      ? 'ہم آپ کو کیا کہیں؟'
      : language == AppLanguage.romanUrdu
          ? 'Hum aap ko kya kahein?'
          : 'What should we call you?';

  String get micUnavailable => language == AppLanguage.urdu
      ? 'مائیکروفون دستیاب نہیں۔ براہ کرم سوال لکھیں۔'
      : language == AppLanguage.romanUrdu
          ? 'Microphone available nahi. Barah-e-karam sawal likhein.'
          : 'Microphone speech is not available. Please type your question.';

  String get simulationOnly => language == AppLanguage.urdu
      ? 'صرف مشق — حقیقی رقم نہیں۔'
      : language == AppLanguage.romanUrdu
          ? 'Sirf mashq — haqiqi raqam nahi.'
          : 'SIMULATION ONLY — NO REAL MONEY.';

  List<String> get suggestedQuestions {
    switch (language) {
      case AppLanguage.urdu:
        return const [
          'واٹس ایپ کیسے استعمال کریں؟',
          'ویڈیو کال کیسے کریں؟',
          'وائی فائی کیسے جوڑیں؟',
          'آن لائن بینکنگ کیسے کریں؟',
          'تصویر کیسے بھیجیں؟',
          'دھوکہ کیسے پہچانیں؟',
        ];
      case AppLanguage.romanUrdu:
        return const [
          'WhatsApp kaise use karein?',
          'Video call kaise karein?',
          'Wi-Fi kaise connect karein?',
          'Online banking kaise karein?',
          'Photo kaise bhejein?',
          'Scam kaise pehchanein?',
        ];
      case AppLanguage.english:
        return const [
          'How do I use WhatsApp?',
          'How do I make a video call?',
          'How do I connect Wi-Fi?',
          'How do I use online banking?',
          'How do I send a photo?',
          'How do I identify a scam?',
        ];
    }
  }

  String get aiWelcome {
    switch (language) {
      case AppLanguage.urdu:
        return 'السلام علیکم! میں ٹیک ساتھی ہوں، آپ کا صبر کرنے والا ٹیکنالوجی استاد۔\n\nمجھ سے کچھ بھی پوچھیں — یا نیچے تجویز کردہ سوال منتخب کریں۔';
      case AppLanguage.romanUrdu:
        return 'Assalam-o-Alaikum! Main TechSathi hoon, aap ka sabr karne wala technology teacher.\n\nMujh se kuch bhi poochhein — ya neeche suggested sawal chunein.';
      case AppLanguage.english:
        return 'Assalam-o-Alaikum! I am TechSaathi, your patient technology teacher.\n\nAsk me anything — or choose a suggested question below.';
    }
  }
}
