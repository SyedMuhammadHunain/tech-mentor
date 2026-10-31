enum AppLanguage { english, urdu, romanUrdu }

enum SkillLevel { completelyNew, knowsALittle, basicApps }

enum LearningStyle { stepByStepText, voice, both }

extension AppLanguageX on AppLanguage {
  String get label {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.urdu:
        return 'اردو';
      case AppLanguage.romanUrdu:
        return 'Roman Urdu';
    }
  }

  String get code {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.urdu:
        return 'ur';
      case AppLanguage.romanUrdu:
        return 'roman_ur';
    }
  }

  bool get isRtl => this == AppLanguage.urdu;

  static AppLanguage fromCode(String? code) {
    switch (code) {
      case 'ur':
        return AppLanguage.urdu;
      case 'roman_ur':
        return AppLanguage.romanUrdu;
      default:
        return AppLanguage.english;
    }
  }
}

extension SkillLevelX on SkillLevel {
  String get label {
    switch (this) {
      case SkillLevel.completelyNew:
        return 'I am completely new.';
      case SkillLevel.knowsALittle:
        return 'I know a little.';
      case SkillLevel.basicApps:
        return 'I can use basic applications.';
    }
  }

  String get storageKey => name;
}

extension LearningStyleX on LearningStyle {
  String get label {
    switch (this) {
      case LearningStyle.stepByStepText:
        return 'Step-by-step text';
      case LearningStyle.voice:
        return 'Voice explanations';
      case LearningStyle.both:
        return 'Both voice and text';
    }
  }
}

class UserPreferences {
  const UserPreferences({
    this.name = '',
    this.language = AppLanguage.english,
    this.skillLevel = SkillLevel.completelyNew,
    this.learningStyle = LearningStyle.both,
    this.textScale = 1.0,
    this.voiceEnabled = true,
    this.notificationsEnabled = true,
    this.onboardingComplete = false,
    this.lessonsCompleted = const [],
    this.practiceCompleted = const [],
    this.quizScores = const {},
    this.learningStreak = 0,
    this.lastLessonId,
    this.lastActiveDate,
    this.independentCompletions = const [],
  });

  final String name;
  final AppLanguage language;
  final SkillLevel skillLevel;
  final LearningStyle learningStyle;
  final double textScale;
  final bool voiceEnabled;
  final bool notificationsEnabled;
  final bool onboardingComplete;
  final List<String> lessonsCompleted;
  final List<String> practiceCompleted;
  final Map<String, int> quizScores;
  final int learningStreak;
  final String? lastLessonId;
  final String? lastActiveDate;
  final List<String> independentCompletions;

  UserPreferences copyWith({
    String? name,
    AppLanguage? language,
    SkillLevel? skillLevel,
    LearningStyle? learningStyle,
    double? textScale,
    bool? voiceEnabled,
    bool? notificationsEnabled,
    bool? onboardingComplete,
    List<String>? lessonsCompleted,
    List<String>? practiceCompleted,
    Map<String, int>? quizScores,
    int? learningStreak,
    String? lastLessonId,
    String? lastActiveDate,
    List<String>? independentCompletions,
  }) {
    return UserPreferences(
      name: name ?? this.name,
      language: language ?? this.language,
      skillLevel: skillLevel ?? this.skillLevel,
      learningStyle: learningStyle ?? this.learningStyle,
      textScale: textScale ?? this.textScale,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      practiceCompleted: practiceCompleted ?? this.practiceCompleted,
      quizScores: quizScores ?? this.quizScores,
      learningStreak: learningStreak ?? this.learningStreak,
      lastLessonId: lastLessonId ?? this.lastLessonId,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      independentCompletions:
          independentCompletions ?? this.independentCompletions,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'preferredLanguage': language.code,
        'skillLevel': skillLevel.name,
        'learningStyle': learningStyle.name,
        'textScale': textScale,
        'voiceEnabled': voiceEnabled,
        'notificationsEnabled': notificationsEnabled,
        'onboardingComplete': onboardingComplete,
        'lessonsCompleted': lessonsCompleted,
        'practiceCompleted': practiceCompleted,
        'quizScores': quizScores,
        'learningStreak': learningStreak,
        'lastLessonId': lastLessonId,
        'lastActiveDate': lastActiveDate,
        'independentCompletions': independentCompletions,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    final scoresRaw = json['quizScores'];
    final scores = <String, int>{};
    if (scoresRaw is Map) {
      scoresRaw.forEach((k, v) {
        scores[k.toString()] = (v is int) ? v : int.tryParse('$v') ?? 0;
      });
    }
    return UserPreferences(
      name: json['name'] as String? ?? '',
      language: AppLanguageX.fromCode(json['preferredLanguage'] as String?),
      skillLevel: SkillLevel.values.firstWhere(
        (e) => e.name == json['skillLevel'],
        orElse: () => SkillLevel.completelyNew,
      ),
      learningStyle: LearningStyle.values.firstWhere(
        (e) => e.name == json['learningStyle'],
        orElse: () => LearningStyle.both,
      ),
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
      voiceEnabled: json['voiceEnabled'] as bool? ?? true,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      lessonsCompleted: List<String>.from(json['lessonsCompleted'] ?? const []),
      practiceCompleted:
          List<String>.from(json['practiceCompleted'] ?? const []),
      quizScores: scores,
      learningStreak: json['learningStreak'] as int? ?? 0,
      lastLessonId: json['lastLessonId'] as String?,
      lastActiveDate: json['lastActiveDate'] as String?,
      independentCompletions:
          List<String>.from(json['independentCompletions'] ?? const []),
    );
  }
}
