import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/ts_button.dart';
import '../../../core/widgets/ts_logo.dart';
import '../../../data/models/user_preferences.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  int _page = 0;
  AppLanguage _language = AppLanguage.english;
  SkillLevel _skill = SkillLevel.completelyNew;
  LearningStyle _style = LearningStyle.both;

  AppStrings get _s => AppStrings(_language);

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _finish() async {
    await ref.read(userPreferencesProvider.notifier).completeOnboarding(
          name: _nameController.text,
          language: _language,
          skillLevel: _skill,
          learningStyle: _style,
        );
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final s = _s;
    return Directionality(
      textDirection: _language.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: List.generate(5, (i) {
                    return Expanded(
                      child: Container(
                        height: 6,
                        margin: EdgeInsets.only(right: i == 4 ? 0 : 6),
                        decoration: BoxDecoration(
                          color:
                              i <= _page ? AppColors.primary : AppColors.border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    _WelcomePage(
                      strings: s,
                      onNext: _next,
                      nameController: _nameController,
                    ),
                    _LanguagePage(
                      strings: s,
                      selected: _language,
                      onChanged: (v) => setState(() => _language = v),
                      onNext: _next,
                    ),
                    _ExperiencePage(
                      strings: s,
                      selected: _skill,
                      onChanged: (v) => setState(() => _skill = v),
                      onNext: _next,
                    ),
                    _StylePage(
                      strings: s,
                      selected: _style,
                      onChanged: (v) => setState(() => _style = v),
                      onNext: _next,
                    ),
                    _CompletePage(strings: s, onStart: _finish),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({
    required this.strings,
    required this.onNext,
    required this.nameController,
  });

  final AppStrings strings;
  final VoidCallback onNext;
  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const TsLogo(size: 88),
          const SizedBox(height: 28),
          Text(
            strings.welcomeTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            strings.welcomeDesc,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.secondaryTeal,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.elderly, size: 56, color: AppColors.primary),
                SizedBox(height: 8),
                Text(
                  'Learning at your own pace',
                  style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: strings.yourName,
              hintText: 'Name',
            ),
          ),
          const Spacer(),
          TsButton(
            label: strings.getStarted,
            onPressed: onNext,
            icon: Icons.arrow_forward,
          ),
        ],
      ),
    );
  }
}

class _LanguagePage extends StatelessWidget {
  const _LanguagePage({
    required this.strings,
    required this.selected,
    required this.onChanged,
    required this.onNext,
  });

  final AppStrings strings;
  final AppLanguage selected;
  final ValueChanged<AppLanguage> onChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            strings.preferredLanguage,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          for (final lang in AppLanguage.values) ...[
            TsChoiceCard(
              label: lang.label,
              selected: selected == lang,
              onTap: () => onChanged(lang),
            ),
            const SizedBox(height: 12),
          ],
          const Spacer(),
          TsButton(label: strings.continueLabel, onPressed: onNext),
        ],
      ),
    );
  }
}

class _ExperiencePage extends StatelessWidget {
  const _ExperiencePage({
    required this.strings,
    required this.selected,
    required this.onChanged,
    required this.onNext,
  });

  final AppStrings strings;
  final SkillLevel selected;
  final ValueChanged<SkillLevel> onChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            strings.comfortQuestion,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          for (final level in SkillLevel.values) ...[
            TsChoiceCard(
              label: level.label,
              selected: selected == level,
              onTap: () => onChanged(level),
            ),
            const SizedBox(height: 12),
          ],
          const Spacer(),
          TsButton(label: strings.continueLabel, onPressed: onNext),
        ],
      ),
    );
  }
}

class _StylePage extends StatelessWidget {
  const _StylePage({
    required this.strings,
    required this.selected,
    required this.onChanged,
    required this.onNext,
  });

  final AppStrings strings;
  final LearningStyle selected;
  final ValueChanged<LearningStyle> onChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            strings.teachingStyle,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          for (final style in LearningStyle.values) ...[
            TsChoiceCard(
              label: style.label,
              selected: selected == style,
              onTap: () => onChanged(style),
            ),
            const SizedBox(height: 12),
          ],
          const Spacer(),
          TsButton(label: strings.continueLabel, onPressed: onNext),
        ],
      ),
    );
  }
}

class _CompletePage extends StatelessWidget {
  const _CompletePage({required this.strings, required this.onStart});

  final AppStrings strings;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          const Icon(Icons.celebration_outlined,
              size: 72, color: AppColors.primary),
          const SizedBox(height: 20),
          Text(
            strings.letsLearn,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          TsButton(
            label: strings.startLearning,
            onPressed: onStart,
            icon: Icons.school_outlined,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
