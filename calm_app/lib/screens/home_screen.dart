import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../widgets/common_widgets.dart';
import 'audio_player_screen.dart';
import 'mood_checkin_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.midnight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Find your calm',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ],
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.1),
                    Row(
                      children: [
                        // Streak badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: Row(
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(
                                '${state.streakDays}',
                                style: const TextStyle(
                                  color: AppTheme.gold,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppTheme.cardSurface,
                          child: const Text('✨', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: const SizedBox(height: 28)),

          // ── Daily Calm Card ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _DailyCalmCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AudioPlayerScreen(
                      session: dailyCalmSession,
                      onComplete: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MoodCheckInScreen()),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05),
          ),

          SliverToBoxAdapter(child: const SizedBox(height: 28)),

          // ── Quick Actions ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Quick Start'),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _QuickAction(
                        emoji: '🌬️',
                        label: 'Breathe',
                        color: AppTheme.sage,
                        onTap: () => Navigator.pushNamed(context, '/breathe'),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        emoji: '🌙',
                        label: 'Sleep',
                        color: AppTheme.lavender,
                        onTap: () => Navigator.pushNamed(context, '/sleep'),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        emoji: '🧘',
                        label: 'Meditate',
                        color: AppTheme.gold,
                        onTap: () => Navigator.pushNamed(context, '/meditate'),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        emoji: '😊',
                        label: 'Mood',
                        color: AppTheme.rose,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MoodCheckInScreen()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),
          ),

          SliverToBoxAdapter(child: const SizedBox(height: 28)),

          // ── Your Stats ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'This Week'),
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
                ],
              ),
            ).animate().fadeIn(delay: 500.ms),
          ),

          SliverToBoxAdapter(child: const SizedBox(height: 28)),

          // ── Recommended ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const SectionHeader(title: 'Recommended'),
            ).animate().fadeIn(delay: 600.ms),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 14)),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 150,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: meditationSessions.length,
                itemBuilder: (ctx, i) => Padding(
                  padding: EdgeInsets.only(right: i < meditationSessions.length - 1 ? 14 : 0),
                  child: GradientSessionCard(
                    session: meditationSessions[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AudioPlayerScreen(
                          session: meditationSessions[i],
                          onComplete: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MoodCheckInScreen()),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 650.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ── Daily Calm Hero Card ───────────────────────────────────────────────────────

class _DailyCalmCard extends StatelessWidget {
  final VoidCallback onTap;
  const _DailyCalmCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B3A2F), Color(0xFF0F2820), Color(0xFF071510)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.sage.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.sage.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.sage.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.sage.withOpacity(0.04),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.sage.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.sage.withOpacity(0.4)),
                        ),
                        child: const Text(
                          'TODAY\'S SESSION',
                          style: TextStyle(
                            color: AppTheme.sageLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    'Daily Calm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Morning mindfulness · 10 min',
                    style: TextStyle(color: AppTheme.sageLight, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.sage,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppTheme.glowSage,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Begin your practice',
                        style: TextStyle(
                          color: AppTheme.sageLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Action Button ────────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
