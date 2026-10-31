import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/firebase_bootstrap.dart';
import '../../../core/widgets/ts_button.dart';
import '../../../core/widgets/ts_card.dart';
import '../../../data/models/user_preferences.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userPreferencesProvider);
    final notifier = ref.read(userPreferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TsCard(
            child: Row(
              children: [
                const Icon(Icons.account_circle,
                    size: 64, color: AppColors.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.isEmpty ? 'Friend' : user.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        user.skillLevel.label,
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
          const SizedBox(height: 20),
          const Text('Preferred language',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final lang in AppLanguage.values)
            RadioListTile<AppLanguage>(
              value: lang,
              groupValue: user.language,
              title: Text(lang.label, style: const TextStyle(fontSize: 17)),
              onChanged: (v) {
                if (v != null) notifier.update((s) => s.copyWith(language: v));
              },
            ),
          const SizedBox(height: 8),
          const Text('Explanation level',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          for (final level in SkillLevel.values)
            RadioListTile<SkillLevel>(
              value: level,
              groupValue: user.skillLevel,
              title: Text(level.label, style: const TextStyle(fontSize: 16)),
              onChanged: (v) {
                if (v != null) {
                  notifier.update((s) => s.copyWith(skillLevel: v));
                }
              },
            ),
          SwitchListTile(
            title: const Text('Voice responses', style: TextStyle(fontSize: 17)),
            value: user.voiceEnabled,
            onChanged: (v) =>
                notifier.update((s) => s.copyWith(voiceEnabled: v)),
          ),
          const Text('Text size',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Slider(
            value: user.textScale,
            min: 0.9,
            max: 1.3,
            divisions: 4,
            label: user.textScale.toStringAsFixed(1),
            onChanged: (v) =>
                notifier.update((s) => s.copyWith(textScale: v)),
          ),
          SwitchListTile(
            title:
                const Text('Learning reminders', style: TextStyle(fontSize: 17)),
            value: user.notificationsEnabled,
            onChanged: (v) =>
                notifier.update((s) => s.copyWith(notificationsEnabled: v)),
          ),
          const SizedBox(height: 12),
          TsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Privacy',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  'TechSaathi never asks for ATM PIN, banking password, OTP, CVV, or card credentials. Screenshots are not stored permanently. Progress is saved on this device'
                  '${FirebaseBootstrap.isAvailable ? ' and synced to your Firebase account.' : '.'}',
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('About TechSaathi',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(AppConstants.tagline,
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text(AppConstants.finalTagline,
                    style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TsButton(
            label: 'Log out (reset local profile)',
            isPrimary: false,
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Log out?'),
                  content: const Text(
                    'This clears onboarding preferences on this device so you can set up again.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Log out'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await notifier.logoutLocal();
                if (context.mounted) context.go('/onboarding');
              }
            },
          ),
        ],
      ),
    );
  }
}
