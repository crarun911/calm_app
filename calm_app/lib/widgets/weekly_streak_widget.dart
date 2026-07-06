// Add this widget to home_screen.dart or profile_screen.dart
// Shows 7 dots representing last 7 days of meditation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';

class WeeklyStreakWidget extends StatelessWidget {
  const WeeklyStreakWidget({super.key});

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final week = state.weeklyStreak;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Streak',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '${state.streakDays} days',
                    style: const TextStyle(
                      color: AppTheme.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final isActive = i < week.length && week[i];
              final isToday = i == 6;
              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isActive ? AppTheme.sageGradient : null,
                      color: isActive ? null : AppTheme.cardSurface2,
                      border: Border.all(
                        color: isToday && !isActive
                            ? AppTheme.sage.withOpacity(0.5)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppTheme.sage.withOpacity(0.3),
                                blurRadius: 8,
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isActive
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _days[i],
                    style: TextStyle(
                      color: isActive
                          ? AppTheme.sage
                          : isToday
                              ? AppTheme.textPrimary
                              : AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: isToday
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
