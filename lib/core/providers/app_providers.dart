import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_preferences.dart';
import '../../data/repositories/user_repository.dart';
import '../services/ai_service.dart';
import '../services/voice_service.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final aiServiceProvider = Provider<AiService>((ref) => AiService());

final voiceServiceProvider = Provider<VoiceService>((ref) {
  final service = VoiceService();
  ref.onDispose(service.dispose);
  return service;
});

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  return UserPreferencesNotifier(ref.watch(userRepositoryProvider));
});

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  UserPreferencesNotifier(this._repo) : super(const UserPreferences()) {
    _load();
  }

  final UserRepository _repo;

  Future<void> _load() async {
    state = await _repo.load();
  }

  Future<void> update(UserPreferences Function(UserPreferences) fn) async {
    state = fn(state);
    await _repo.save(state);
  }

  Future<void> completeOnboarding({
    required String name,
    required AppLanguage language,
    required SkillLevel skillLevel,
    required LearningStyle learningStyle,
  }) async {
    await update(
      (s) => s.copyWith(
        name: name.trim().isEmpty ? 'Friend' : name.trim(),
        language: language,
        skillLevel: skillLevel,
        learningStyle: learningStyle,
        onboardingComplete: true,
        lastActiveDate: DateTime.now().toIso8601String().substring(0, 10),
        learningStreak: 1,
      ),
    );
  }

  Future<void> markLessonComplete(
    String lessonId, {
    int? quizScore,
    bool independent = false,
  }) async {
    final completed = {...state.lessonsCompleted, lessonId}.toList();
    final scores = Map<String, int>.from(state.quizScores);
    if (quizScore != null) scores[lessonId] = quizScore;
    final independentList = independent
        ? {...state.independentCompletions, lessonId}.toList()
        : state.independentCompletions;

    await update(
      (s) => s.copyWith(
        lessonsCompleted: completed,
        quizScores: scores,
        independentCompletions: independentList,
        lastLessonId: lessonId,
        lastActiveDate: DateTime.now().toIso8601String().substring(0, 10),
      ),
    );
    await _repo.saveLessonProgress(
      lessonId: lessonId,
      completed: true,
      quizScore: quizScore,
      independentCompletion: independent,
    );
  }

  Future<void> markPracticeComplete(String practiceId) async {
    final list = {...state.practiceCompleted, practiceId}.toList();
    await update((s) => s.copyWith(practiceCompleted: list));
  }

  Future<void> setLastLesson(String lessonId) async {
    await update((s) => s.copyWith(lastLessonId: lessonId));
  }

  Future<void> logoutLocal() async {
    await _repo.clearLocal();
    state = const UserPreferences();
  }
}
