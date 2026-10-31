import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/ts_button.dart';
import '../../../core/widgets/ts_card.dart';
import '../services/banking_content.dart';

class BankingLessonScreen extends ConsumerStatefulWidget {
  const BankingLessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<BankingLessonScreen> createState() =>
      _BankingLessonScreenState();
}

class _BankingLessonScreenState extends ConsumerState<BankingLessonScreen> {
  int _step = 0;
  int? _selected;
  bool _answered = false;
  bool _usedHints = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userPreferencesProvider.notifier).setLastLesson(widget.lessonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lesson = BankingContent.byId(widget.lessonId);
    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lesson')),
        body: const Center(child: Text('Lesson not found')),
      );
    }

    final pages = [
      _IntroPage(lesson: lesson, onNext: () => setState(() => _step = 1)),
      _StepsPage(
        lesson: lesson,
        onHint: () => _usedHints = true,
        onNext: () => setState(() => _step = 2),
      ),
      _QuizPage(
        lesson: lesson,
        selected: _selected,
        answered: _answered,
        onSelect: (i) => setState(() => _selected = i),
        onSubmit: () => setState(() => _answered = true),
        onFinish: () async {
          final q = lesson.quiz.first;
          final score = (_selected == q.answerIndex) ? 100 : 50;
          await ref.read(userPreferencesProvider.notifier).markLessonComplete(
                lesson.id,
                quizScore: score,
                independent: !_usedHints && _selected == q.answerIndex,
              );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Well done! You learned: ${lesson.title}'),
              ),
            );
            context.pop();
          }
        },
        onPractice: () => context.push('/practice-lab'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: pages[_step],
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.lesson, required this.onNext});
  final dynamic lesson;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(lesson.introduction,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        TsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('What it means',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(lesson.meaning, style: const TextStyle(fontSize: 17)),
              const SizedBox(height: 16),
              const Text('Why it is used',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(lesson.whyUsed, style: const TextStyle(fontSize: 17)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.secondaryTeal,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_outlined, size: 40, color: AppColors.primary),
              SizedBox(height: 8),
              Text('Simple visual guide', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TsButton(label: 'Continue to steps', onPressed: onNext),
      ],
    );
  }
}

class _StepsPage extends StatelessWidget {
  const _StepsPage({
    required this.lesson,
    required this.onNext,
    required this.onHint,
  });
  final dynamic lesson;
  final VoidCallback onNext;
  final VoidCallback onHint;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Step-by-step',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        for (var i = 0; i < lesson.steps.length; i++) ...[
          TsCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  child: Text('${i + 1}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(lesson.steps[i],
                      style: const TextStyle(fontSize: 17)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 8),
        const Text('Common mistakes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        for (final m in lesson.commonMistakes)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('• $m', style: const TextStyle(fontSize: 16)),
          ),
        const SizedBox(height: 12),
        TsCard(
          color: AppColors.simulationBanner,
          child: Text('Safety: ${lesson.safetyAdvice}',
              style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 12),
        TsButton(
          label: 'Show practice tip',
          isPrimary: false,
          onPressed: () {
            onHint();
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Practice tip'),
                content: Text(lesson.practicePrompt,
                    style: const TextStyle(fontSize: 17)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        TsButton(label: "Let's Practise / Quiz", onPressed: onNext),
      ],
    );
  }
}

class _QuizPage extends StatelessWidget {
  const _QuizPage({
    required this.lesson,
    required this.selected,
    required this.answered,
    required this.onSelect,
    required this.onSubmit,
    required this.onFinish,
    required this.onPractice,
  });

  final dynamic lesson;
  final int? selected;
  final bool answered;
  final ValueChanged<int> onSelect;
  final VoidCallback onSubmit;
  final VoidCallback onFinish;
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) {
    final q = lesson.quiz.first as dynamic;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Short quiz',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Text(q.question, style: const TextStyle(fontSize: 19)),
        const SizedBox(height: 16),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TsCard(
              onTap: answered ? null : () => onSelect(i),
              color: answered
                  ? (i == q.answerIndex
                      ? AppColors.secondaryTeal
                      : (selected == i ? const Color(0xFFFFE8E6) : null))
                  : (selected == i ? AppColors.secondaryTeal : null),
              child: Text(q.options[i], style: const TextStyle(fontSize: 17)),
            ),
          ),
        if (answered) ...[
          const SizedBox(height: 8),
          Text(q.explanation, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          TsButton(label: 'Complete lesson', onPressed: onFinish),
          const SizedBox(height: 10),
          TsButton(
            label: 'Open Demo Bank practice',
            isPrimary: false,
            onPressed: onPractice,
          ),
        ] else
          TsButton(
            label: 'Check answer',
            onPressed: selected == null ? null : onSubmit,
          ),
      ],
    );
  }
}
