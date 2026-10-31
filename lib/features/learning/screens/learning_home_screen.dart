import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/ts_card.dart';
import '../services/learning_content.dart';

class LearningHomeScreen extends StatelessWidget {
  const LearningHomeScreen({super.key});

  IconData _icon(String name) {
    switch (name) {
      case 'chat':
        return Icons.chat_outlined;
      case 'wifi':
        return Icons.wifi;
      case 'videocam':
        return Icons.videocam_outlined;
      case 'payments':
        return Icons.payments_outlined;
      case 'account_balance':
        return Icons.account_balance_outlined;
      case 'shield':
        return Icons.shield_outlined;
      case 'public':
        return Icons.public;
      default:
        return Icons.phone_android;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = LearningContent.categories;
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Small lessons. Clear steps. Your pace.',
            style: TextStyle(fontSize: 17, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TsCard(
            onTap: () => context.push('/banking'),
            child: const Row(
              children: [
                Icon(Icons.account_balance, color: AppColors.primary, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Also explore Banking Saathi lessons',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final cat in categories) ...[
            TsCard(
              onTap: () => context.push('/learn/category/${cat.id}'),
              semanticLabel: cat.title,
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryTeal,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_icon(cat.iconName),
                        color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.title,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat.description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 28),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
