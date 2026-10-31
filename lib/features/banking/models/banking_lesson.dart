class BankingLesson {
  const BankingLesson({
    required this.id,
    required this.title,
    required this.titleUrdu,
    required this.introduction,
    required this.meaning,
    required this.whyUsed,
    required this.steps,
    required this.commonMistakes,
    required this.safetyAdvice,
    required this.practicePrompt,
    required this.quiz,
  });

  final String id;
  final String title;
  final String titleUrdu;
  final String introduction;
  final String meaning;
  final String whyUsed;
  final List<String> steps;
  final List<String> commonMistakes;
  final String safetyAdvice;
  final String practicePrompt;
  final List<QuizQuestion> quiz;
}

class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;
}

class LearningCategory {
  const LearningCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.lessons,
  });

  final String id;
  final String title;
  final String description;
  final String iconName;
  final List<LearningLesson> lessons;
}

class LearningLesson {
  const LearningLesson({
    required this.id,
    required this.title,
    required this.introduction,
    required this.explanation,
    required this.steps,
    required this.practiceHint,
    required this.quiz,
  });

  final String id;
  final String title;
  final String introduction;
  final String explanation;
  final List<String> steps;
  final String practiceHint;
  final List<QuizQuestion> quiz;
}
