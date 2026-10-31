import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/ts_logo.dart';
import '../../../data/repositories/user_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Ensure prefs are loaded before routing.
    final prefs = await UserRepository().load();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    // Sync notifier state if load finished after construction.
    if (prefs.onboardingComplete !=
        ref.read(userPreferencesProvider).onboardingComplete) {
      await ref.read(userPreferencesProvider.notifier).update((_) => prefs);
    }
    if (!mounted) return;
    final done = ref.read(userPreferencesProvider).onboardingComplete ||
        prefs.onboardingComplete;
    context.go(done ? '/home' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TsLogo(size: 96),
                const SizedBox(height: 20),
                Text(
                  AppConstants.tagline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
