import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
          color: AppColors.secondaryBg,
        ),
        child: SafeArea(
          child: NavigationBar(
            height: 72,
            backgroundColor: AppColors.secondaryBg,
            indicatorColor: AppColors.secondaryTeal,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onTap,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined, size: 28),
                selectedIcon: const Icon(Icons.home, size: 28),
                label: s.home,
              ),
              NavigationDestination(
                icon: const Icon(Icons.menu_book_outlined, size: 28),
                selectedIcon: const Icon(Icons.menu_book, size: 28),
                label: s.learn,
              ),
              NavigationDestination(
                icon: const Icon(Icons.fitness_center_outlined, size: 28),
                selectedIcon: const Icon(Icons.fitness_center, size: 28),
                label: s.practice,
              ),
              NavigationDestination(
                icon: const Icon(Icons.insights_outlined, size: 28),
                selectedIcon: const Icon(Icons.insights, size: 28),
                label: s.myProgress,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PracticeHubScreen extends ConsumerWidget {
  const PracticeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(s.practice)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            s.simulationOnly,
            style: const TextStyle(fontSize: 17, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          _PracticeTile(
            icon: Icons.account_balance,
            title: 'Demo Bank Transfer',
            subtitle: s.bankingSaathiDesc,
            onTap: () => context.push('/practice-lab'),
          ),
          const SizedBox(height: 12),
          _PracticeTile(
            icon: Icons.shield_outlined,
            title: s.scamShield,
            subtitle: s.scamShieldDesc,
            onTap: () => context.push('/scamshield'),
          ),
          const SizedBox(height: 12),
          _PracticeTile(
            icon: Icons.screenshot_outlined,
            title: s.explainScreen,
            subtitle: s.explainScreenDesc,
            onTap: () => context.push('/explain-screen'),
          ),
          const SizedBox(height: 12),
          _PracticeTile(
            icon: Icons.smart_toy_outlined,
            title: s.aiTeacher,
            subtitle: s.aiTeacherDesc,
            onTap: () => context.push('/ai-teacher'),
          ),
        ],
      ),
    );
  }
}

class _PracticeTile extends StatelessWidget {
  const _PracticeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.secondaryBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.secondaryTeal,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
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
      ),
    );
  }
}
