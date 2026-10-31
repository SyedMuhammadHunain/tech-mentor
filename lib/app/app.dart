import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/app_providers.dart';
import '../data/models/user_preferences.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class TechSaathiApp extends ConsumerWidget {
  const TechSaathiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final prefs = ref.watch(userPreferencesProvider);

    return MaterialApp.router(
      title: 'TechSaathi AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(prefs.textScale),
          ),
          child: Directionality(
            textDirection:
                prefs.language.isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
