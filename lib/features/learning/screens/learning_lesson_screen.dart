import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/ts_button.dart';
import '../../../core/widgets/ts_card.dart';
import '../services/learning_content.dart';

class LearningLessonScreen extends ConsumerStatefulWidget {
  const LearningLessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LearningLessonScreen> createState() =>
      _LearningLessonScreenState();
}

class _LearningLessonScreenState extends ConsumerState<LearningLessonScreen> {
  int _page = 0;
  int? _selected;
  bool _answered = false;
  bool _guided = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userPreferencesProvider.notifier).setLastLesson(widget.lessonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lesson = LearningContent.lessonById(widget.lessonId);
    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lesson')),
        body: const Center(child: Text('Lesson not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_page == 0) ...[
            const Text('1. Introduction',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(lesson.introduction, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Text('2. Explanation',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(lesson.explanation, style: const TextStyle(fontSize: 17)),
            const SizedBox(height: 16),
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.secondaryTeal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.visibility_outlined,
                      size: 36, color: AppColors.primary),
                  SizedBox(height: 8),
                  Text('Visual demonstration', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TsButton(label: 'Guided steps', onPressed: () => setState(() => _page = 1)),
          ] else if (_page == 1) ...[
            Row(
              children: [
                const Expanded(
                  child: Text('3. Guided steps',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                ),
                Switch(
                  value: _guided,
                  onChanged: (v) => setState(() => _guided = v),
                ),
              ],
            ),
            Text(
              _guided
                  ? 'Hints are on — follow along.'
                  : 'Independent practice — try without reading every tip.',
              style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < lesson.steps.length; i++) ...[
              TsCard(
                child: Text(
                  _guided
                      ? 'Step ${i + 1}: ${lesson.steps[i]}'
                      : 'Step ${i + 1}: Try this yourself',
                  style: const TextStyle(fontSize: 17),
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            const Text('4. Independent practice',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(lesson.practiceHint, style: const TextStyle(fontSize: 17)),
            const SizedBox(height: 20),
            TsButton(label: 'Take quiz', onPressed: () => setState(() => _page = 2)),
          ] else ...[
            const Text('5. Quiz',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text(lesson.quiz.first.question,
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            for (var i = 0; i < lesson.quiz.first.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TsCard(
                  onTap: _answered ? null : () => setState(() => _selected = i),
                  color: _selected == i ? AppColors.secondaryTeal : null,
                  child: Text(lesson.quiz.first.options[i],
                      style: const TextStyle(fontSize: 17)),
                ),
              ),
            if (_answered) ...[
              Text(lesson.quiz.first.explanation,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              TsButton(
                label: 'Complete lesson',
                onPressed: () async {
                  final correct =
                      _selected == lesson.quiz.first.answerIndex;
                  await ref
                      .read(userPreferencesProvider.notifier)
                      .markLessonComplete(
                        lesson.id,
                        quizScore: correct ? 100 : 50,
                        independent: !_guided && correct,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('You have learned: ${lesson.title}!'),
                      ),
                    );
                    context.pop();
                  }
                },
              ),
            ] else
              TsButton(
                label: 'Check answer',
                onPressed: _selected == null
                    ? null
                    : () => setState(() => _answered = true),
              ),
          ],
        ],
      ),
    );
  }
}
