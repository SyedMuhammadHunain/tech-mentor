import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/ts_card.dart';
import '../services/learning_content.dart';

class LearningCategoryScreen extends StatelessWidget {
  const LearningCategoryScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final category = LearningContent.categoryById(categoryId);
    if (category == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Category')),
        body: const Center(child: Text('Category not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(category.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            category.description,
            style: const TextStyle(fontSize: 17, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          for (final lesson in category.lessons) ...[
            TsCard(
              onTap: () => context.push('/learn/lesson/${lesson.id}'),
              child: Row(
                children: [
                  const Icon(Icons.article_outlined,
                      color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
