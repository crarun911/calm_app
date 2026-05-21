import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _moodEmoji(MoodType? mood) {
    switch (mood) {
      case MoodType.great:
        return '😁';
      case MoodType.good:
        return '🙂';
      case MoodType.okay:
        return '😐';
      case MoodType.sad:
        return '😔';
      case MoodType.stressed:
        return '😣';
      default:
        return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.midnight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.sageGradient,
                            boxShadow: AppTheme.glowSage,
                          ),
                          child: const Center(
                            child: Text('✨', style: TextStyle(fontSize: 36)),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.gold,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.midnight, width: 2),
                            ),
                            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.8, 0.8)),

                    const SizedBox(height: 16),

                    Text(
                      'Alex Meridian',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 4),

                    const Text(
                      'Meditating since January 2024',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ).animate().fadeIn(delay: 250.ms),

                    const SizedBox(height: 24),

                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.glowGold,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.white, size: 24),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Upgrade to Premium',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    'Unlock all sessions & features',
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                color: Colors.white70, size: 14),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Stats ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Your Journey'),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: StatChip(
                          value: '${state.streakDays}',
                          label: 'Day Streak',
                          icon: Icons.local_fire_department_rounded,
                          color: AppTheme.gold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatChip(
                          value: '${state.minutesMeditated}',
                          label: 'Min Meditated',
                          icon: Icons.self_improvement_rounded,
                          color: AppTheme.sage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatChip(
                          value: '24',
                          label: 'Sessions Done',
                          icon: Icons.check_circle_outline_rounded,
                          color: AppTheme.lavender,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatChip(
                          value: _moodEmoji(state.selectedMood),
                          label: 'Last Mood',
                          icon: Icons.mood_rounded,
                          color: AppTheme.rose,
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn(delay: 350.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Recent moods ──────────────────────────────────────────────
          if (state.moodHistory.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Mood History'),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: state.moodHistory.take(7).map((entry) {
                          return Column(
                            children: [
                              Text(_moodEmoji(entry.mood),
                                  style: const TextStyle(fontSize: 22)),
                              const SizedBox(height: 4),
                              Text(
                                '${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                    color: AppTheme.textMuted, fontSize: 10),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Settings ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Settings'),
                  const SizedBox(height: 14),
                  _SettingsTile(emoji: '🔔', label: 'Reminders', delay: 450),
                  _SettingsTile(emoji: '🎵', label: 'Audio Quality', delay: 490),
                  _SettingsTile(emoji: '🌙', label: 'Dark Mode', delay: 530),
                  _SettingsTile(emoji: '🔒', label: 'Privacy', delay: 570),
                  _SettingsTile(emoji: '💬', label: 'Help & Support', delay: 610),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String emoji;
  final String label;
  final int delay;

  const _SettingsTile({
    required this.emoji,
    required this.label,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: AppTheme.textMuted, size: 14),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn().slideX(begin: 0.05);
  }
}
