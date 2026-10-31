import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/ts_button.dart';
import '../../../core/widgets/ts_card.dart';
import '../../banking/services/banking_content.dart';
import '../../learning/services/learning_content.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userPreferencesProvider);
    final completed = user.lessonsCompleted;
    final practice = user.practiceCompleted;
    final independent = user.independentCompletions;

    String encouragement;
    if (completed.isEmpty) {
      encouragement = "Let's start with something friendly today.";
    } else {
      final lastId = completed.last;
      final banking = BankingContent.byId(lastId);
      final learning = LearningContent.lessonById(lastId);
      final title = banking?.title ?? learning?.title ?? 'a new skill';
      encouragement = 'You have learned how to understand $title!';
    }

    String nextHint = "Let's practise online banking next.";
    if (!completed.contains('learning_money_transfers')) {
      nextHint = "Let's practise online banking next.";
    } else if (!practice.contains('scamshield_check')) {
      nextHint = "Let's practise spotting scams next.";
    } else {
      nextHint = 'Ask AI Teacher anything you still find confusing.';
    }

    final badges = <String>[];
    if (completed.isNotEmpty) badges.add('First Lesson');
    if (completed.length >= 3) badges.add('Curious Learner');
    if (practice.contains('demo_bank_transfer')) badges.add('Demo Bank Hero');
    if (practice.contains('scamshield_check')) badges.add('Scam Spotter');
    if (independent.isNotEmpty) badges.add('Growing Independence');

    final needsPractice = <String>[];
    for (final entry in user.quizScores.entries) {
      if (entry.value < 80) {
        final banking = BankingContent.byId(entry.key);
        final learning = LearningContent.lessonById(entry.key);
        needsPractice.add(banking?.title ?? learning?.title ?? entry.key);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Progress')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            encouragement,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            nextHint,
            style: const TextStyle(fontSize: 17, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          TsCard(
            child: Column(
              children: [
                _stat('Lessons completed', '${completed.length}'),
                const Divider(),
                _stat('Practice exercises', '${practice.length}'),
                const Divider(),
                _stat('Learning streak',
                    '${user.learningStreak} day${user.learningStreak == 1 ? '' : 's'}'),
                const Divider(),
                _stat('Independent completions', '${independent.length}'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Achievements',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (badges.isEmpty)
            const Text(
              'Complete a lesson to earn your first badge.',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final b in badges)
                  Chip(
                    avatar: const Icon(Icons.emoji_events_outlined,
                        color: AppColors.primary, size: 20),
                    label: Text(b, style: const TextStyle(fontSize: 15)),
                    backgroundColor: AppColors.secondaryTeal,
                  ),
              ],
            ),
          const SizedBox(height: 20),
          const Text('Categories touched',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final cat in LearningContent.categories)
                if (cat.lessons.any((l) => completed.contains(l.id)))
                  Chip(label: Text(cat.title)),
              if (BankingContent.lessons
                  .any((l) => completed.contains(l.id)))
                const Chip(label: Text('Banking Saathi')),
            ],
          ),
          if (needsPractice.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Skills needing more practice',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final s in needsPractice)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('• $s', style: const TextStyle(fontSize: 16)),
              ),
          ],
          const SizedBox(height: 24),
          TsButton(
            label: 'Continue practising',
            onPressed: () => context.go('/practice'),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 17)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
