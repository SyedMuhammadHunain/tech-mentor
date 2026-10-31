import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
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
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, size: 28),
                selectedIcon: Icon(Icons.home, size: 28),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined, size: 28),
                selectedIcon: Icon(Icons.menu_book, size: 28),
                label: 'Learn',
              ),
              NavigationDestination(
                icon: Icon(Icons.fitness_center_outlined, size: 28),
                selectedIcon: Icon(Icons.fitness_center, size: 28),
                label: 'Practice',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined, size: 28),
                selectedIcon: Icon(Icons.insights, size: 28),
                label: 'My Progress',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hub for practice activities (tab 3).
class PracticeHubScreen extends StatelessWidget {
  const PracticeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Practise safely. No real money. No real passwords.',
            style: TextStyle(fontSize: 17, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          _PracticeTile(
            icon: Icons.account_balance,
            title: 'Demo Bank Transfer',
            subtitle: 'Simulate sending money step by step.',
            onTap: () => context.push('/practice-lab'),
          ),
          const SizedBox(height: 12),
          _PracticeTile(
            icon: Icons.shield_outlined,
            title: 'ScamShield Practice',
            subtitle: 'Check if a message looks suspicious.',
            onTap: () => context.push('/scamshield'),
          ),
          const SizedBox(height: 12),
          _PracticeTile(
            icon: Icons.screenshot_outlined,
            title: 'Explain My Screen',
            subtitle: 'Understand a confusing phone screen.',
            onTap: () => context.push('/explain-screen'),
          ),
          const SizedBox(height: 12),
          _PracticeTile(
            icon: Icons.smart_toy_outlined,
            title: 'Ask AI Teacher',
            subtitle: 'Get patient step-by-step help.',
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
