import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/ts_card.dart';
import '../../../core/widgets/ts_logo.dart';
import '../../banking/services/banking_content.dart';
import '../../learning/services/learning_content.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userPreferencesProvider);
    final s = ref.watch(appStringsProvider);
    final totalLessons = BankingContent.lessons.length +
        LearningContent.categories
            .fold<int>(0, (n, c) => n + c.lessons.length);
    final done = user.lessonsCompleted.length;
    final progress =
        totalLessons == 0 ? 0.0 : (done / totalLessons).clamp(0.0, 1.0);

    String? continueTitle;
    String? continueRoute;
    if (user.lastLessonId != null) {
      final banking = BankingContent.byId(user.lastLessonId!);
      final learning = LearningContent.lessonById(user.lastLessonId!);
      if (banking != null && !user.lessonsCompleted.contains(banking.id)) {
        continueTitle = banking.title;
        continueRoute = '/banking/lesson/${banking.id}';
      } else if (learning != null &&
          !user.lessonsCompleted.contains(learning.id)) {
        continueTitle = learning.title;
        continueRoute = '/learn/lesson/${learning.id}';
      }
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(
              children: [
                const TsLogo(size: 44, showWordmark: false),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.appName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        s.greeting(user.name),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: s.profile,
                  onPressed: () => context.push('/profile'),
                  iconSize: 32,
                  icon: const Icon(Icons.account_circle_outlined),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TsCard(
              color: AppColors.secondaryTeal,
              semanticLabel: s.howCanIHelp,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.howCanIHelp,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.askVoiceOrType,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/ai-teacher'),
                          icon: const Icon(Icons.mic, size: 26),
                          label: Text(s.voice),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/ai-teacher'),
                          icon: const Icon(Icons.chat_bubble_outline, size: 24),
                          label: Text(s.type),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              s.learnWith,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TsFeatureCard(
              title: s.aiTeacher,
              description: s.aiTeacherDesc,
              icon: Icons.smart_toy_outlined,
              onTap: () => context.push('/ai-teacher'),
            ),
            const SizedBox(height: 12),
            TsFeatureCard(
              title: s.bankingSaathi,
              description: s.bankingSaathiDesc,
              icon: Icons.account_balance_outlined,
              onTap: () => context.push('/banking'),
            ),
            const SizedBox(height: 12),
            TsFeatureCard(
              title: s.scamShield,
              description: s.scamShieldDesc,
              icon: Icons.shield_outlined,
              onTap: () => context.push('/scamshield'),
            ),
            const SizedBox(height: 12),
            TsFeatureCard(
              title: s.explainScreen,
              description: s.explainScreenDesc,
              icon: Icons.screenshot_outlined,
              onTap: () => context.push('/explain-screen'),
            ),
            if (continueTitle != null && continueRoute != null) ...[
              const SizedBox(height: 24),
              Text(
                s.continueLearning,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TsCard(
                onTap: () => context.push(continueRoute!),
                semanticLabel: '${s.continueLearning} $continueTitle',
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_outline,
                        color: AppColors.primary, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        continueTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 28),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              s.yourProgress,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TsCard(
              onTap: () => context.go('/progress'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.lessonsCompleted(done),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: AppColors.border,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.streak(user.learningStreak),
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
