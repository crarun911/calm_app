import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import 'home_screen.dart';
import 'meditate_screen.dart';
import 'sleep_screen.dart';
import 'mood_checkin_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _screens = [
    HomeScreen(),
    MeditateScreen(),
    SleepScreen(),
    MoodCheckInScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppTheme.deepNavy,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.midnight,
        body: IndexedStack(
          index: state.currentNavIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppTheme.deepNavy,
            border: Border(
              top: BorderSide(color: AppTheme.divider, width: 0.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    index: 0,
                    current: state.currentNavIndex,
                    onTap: () => state.setNavIndex(0),
                  ),
                  _NavItem(
                    icon: Icons.self_improvement_rounded,
                    label: 'Meditate',
                    index: 1,
                    current: state.currentNavIndex,
                    onTap: () => state.setNavIndex(1),
                  ),
                  _NavItem(
                    icon: Icons.bedtime_rounded,
                    label: 'Sleep',
                    index: 2,
                    current: state.currentNavIndex,
                    onTap: () => state.setNavIndex(2),
                  ),
                  _NavItem(
                    icon: Icons.mood_rounded,
                    label: 'Mood',
                    index: 3,
                    current: state.currentNavIndex,
                    onTap: () => state.setNavIndex(3),
                  ),
                  _NavItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    index: 4,
                    current: state.currentNavIndex,
                    onTap: () => state.setNavIndex(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.sage.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isActive ? AppTheme.sage : AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.sage : AppTheme.textMuted,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
