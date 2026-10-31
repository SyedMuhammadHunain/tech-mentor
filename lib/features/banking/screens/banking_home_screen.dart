import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/ts_button.dart';
import '../../../core/widgets/ts_card.dart';
import '../services/banking_content.dart';

class BankingHomeScreen extends StatelessWidget {
  const BankingHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lessons = BankingContent.lessons;
    return Scaffold(
      appBar: AppBar(title: const Text('Banking Saathi')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Learn Banking, Step by Step.',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Understand digital banking without fear.',
            style: TextStyle(fontSize: 17, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TsCard(
            color: AppColors.simulationBanner,
            child: const Text(
              'We never ask for ATM PIN, password, OTP, CVV, or card credentials. No real bank accounts are connected.',
              style: TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          TsButton(
            label: 'Open Practice Lab (Demo Bank)',
            icon: Icons.account_balance_wallet_outlined,
            onPressed: () => context.push('/practice-lab'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Lesson categories',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < lessons.length; i++) ...[
            TsCard(
              onTap: () => context.push('/banking/lesson/${lessons[i].id}'),
              semanticLabel: lessons[i].title,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.secondaryTeal,
                    foregroundColor: AppColors.primary,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lessons[i].title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          lessons[i].titleUrdu,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 28),
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
