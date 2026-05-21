import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import 'sleep_screen.dart';
import 'meditate_screen.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  String _moodMessage(MoodType? mood) {
    switch (mood) {
      case MoodType.great:
        return 'You\'re thriving today! Keep that energy going.';
      case MoodType.good:
        return 'You\'re doing well. Let\'s make it even better.';
      case MoodType.okay:
        return 'A gentle practice can lift your spirits.';
      case MoodType.sad:
        return 'Be kind to yourself. Rest is healing too.';
      case MoodType.stressed:
        return 'Let\'s ease that tension together.';
      default:
        return 'What would you like to explore today?';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.midnight,
      body: Stack(
        children: [
          // Stars background
          ...List.generate(20, (i) {
            final x = (i * 37.3) % 400;
            final y = (i * 53.7) % 800;
            final size = (i % 3 + 1).toDouble();
            return Positioned(
              left: x,
              top: y,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15 + (i % 4) * 0.1),
                ),
              ),
            );
          }),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: AppTheme.textPrimary, size: 16),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  Text(
                    'For You',
                    style: Theme.of(context).textTheme.displayLarge,
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 8),

                  Text(
                    _moodMessage(state.selectedMood),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 40),

                  // ── Sleep Card ──────────────────────────────────────────
                  _RecommendCard(
                    title: 'Sleep Better Tonight',
                    subtitle: 'Wind down with soothing sleep stories and soundscapes',
                    emoji: '🌙',
                    gradient: AppTheme.sleepGradient,
                    accentColor: AppTheme.lavender,
                    tags: ['Stories', 'Sounds', '20–40 min'],
                    onTap: () => Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const SleepScreen(),
                        transitionsBuilder: (_, anim, __, child) => SlideTransition(
                          position: Tween(
                            begin: const Offset(-1, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                          child: child,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.05),

                  const SizedBox(height: 16),

                  // ── Meditate Card ───────────────────────────────────────
                  _RecommendCard(
                    title: 'Reduce Anxiety',
                    subtitle: 'Guided meditations to calm your nervous system',
                    emoji: '🧘',
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E2A1E), Color(0xFF162516)],
                    ),
                    accentColor: AppTheme.sage,
                    tags: ['Anxiety', 'Stress', '10–20 min'],
                    onTap: () => Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const MeditateScreen(),
                        transitionsBuilder: (_, anim, __, child) => SlideTransition(
                          position: Tween(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                          child: child,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 450.ms).slideX(begin: 0.05),

                  const SizedBox(height: 16),

                  // ── Morning Energy Card ──────────────────────────────────
                  _RecommendCard(
                    title: 'Morning Energy',
                    subtitle: 'Start your day with clarity and intention',
                    emoji: '☀️',
                    gradient: AppTheme.goldGradient,
                    accentColor: AppTheme.gold,
                    tags: ['Energise', 'Focus', '5–15 min'],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MeditateScreen()),
                    ),
                  ).animate().fadeIn(delay: 550.ms).slideX(begin: -0.05),

                  const Spacer(),

                  // ── Back home ───────────────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                      child: const Text(
                        'Return to Home',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Gradient gradient;
  final Color accentColor;
  final List<String> tags;
  final VoidCallback onTap;

  const _RecommendCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradient,
    required this.accentColor,
    required this.tags,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    children: tags
                        .map(
                          (t) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              t,
                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: accentColor, size: 16),
          ],
        ),
      ),
    );
  }
}
