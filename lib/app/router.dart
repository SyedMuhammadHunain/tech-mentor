import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/app_providers.dart';
import '../features/ai_teacher/screens/ai_teacher_screen.dart';
import '../features/banking/screens/banking_home_screen.dart';
import '../features/banking/screens/banking_lesson_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/learning/screens/learning_category_screen.dart';
import '../features/learning/screens/learning_home_screen.dart';
import '../features/learning/screens/learning_lesson_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/onboarding/screens/splash_screen.dart';
import '../features/practice_lab/screens/practice_lab_flow.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/progress/screens/progress_screen.dart';
import '../features/scamshield/screens/scamshield_screen.dart';
import '../features/screen_explainer/screens/screen_explainer_screen.dart';
import '../features/shell/main_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingComplete =
      ref.watch(userPreferencesProvider.select((u) => u.onboardingComplete));

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final path = state.uri.path;
      final isSplash = path == '/splash';
      final isOnboarding = path == '/onboarding';
      if (isSplash) return null;
      if (!onboardingComplete && !isOnboarding) return '/onboarding';
      if (onboardingComplete && isOnboarding) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learn',
                builder: (context, state) => const LearningHomeScreen(),
                routes: [
                  GoRoute(
                    path: 'category/:id',
                    builder: (context, state) => LearningCategoryScreen(
                      categoryId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'lesson/:id',
                    builder: (context, state) => LearningLessonScreen(
                      lessonId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/practice',
                builder: (context, state) => const PracticeHubScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/ai-teacher',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const AiTeacherScreen(),
      ),
      GoRoute(
        path: '/banking',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const BankingHomeScreen(),
        routes: [
          GoRoute(
            path: 'lesson/:id',
            builder: (context, state) => BankingLessonScreen(
              lessonId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/practice-lab',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const PracticeLabFlow(),
      ),
      GoRoute(
        path: '/explain-screen',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const ScreenExplainerScreen(),
      ),
      GoRoute(
        path: '/scamshield',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const ScamShieldScreen(),
      ),
    ],
  );
});
