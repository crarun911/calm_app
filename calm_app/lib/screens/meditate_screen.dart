import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../widgets/common_widgets.dart';
import 'audio_player_screen.dart';
import 'mood_checkin_screen.dart';

class MeditateScreen extends StatefulWidget {
  const MeditateScreen({super.key});

  @override
  State<MeditateScreen> createState() => _MeditateScreenState();
}

class _MeditateScreenState extends State<MeditateScreen> {
  String _activeCategory = 'All';
  final _categories = ['All', 'Anxiety', 'Stress', 'Focus', 'Happiness'];

  List<Session> get _filtered => _activeCategory == 'All'
      ? meditationSessions
      : meditationSessions.where((s) => s.category == _activeCategory).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.midnight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
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
                    const SizedBox(width: 16),
                    Text('Meditate', style: Theme.of(context).textTheme.headlineLarge),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Categories ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => CategoryPill(
                  label: _categories[i],
                  selected: _activeCategory == _categories[i],
                  onTap: () => setState(() => _activeCategory = _categories[i]),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Featured ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const SectionHeader(title: 'Featured'),
            ).animate().fadeIn(delay: 250.ms),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GradientSessionCard(
                session: meditationSessions[0],
                large: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AudioPlayerScreen(
                      session: meditationSessions[0],
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
              ).animate().fadeIn(delay: 300.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── All Sessions ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SectionHeader(
                title: _activeCategory == 'All' ? 'All Sessions' : _activeCategory,
              ),
            ).animate().fadeIn(delay: 350.ms),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final s = _filtered[i];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: _SessionListTile(
                    session: s,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AudioPlayerScreen(
                          session: s,
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
                  ).animate(delay: Duration(milliseconds: 400 + i * 60)).fadeIn().slideY(begin: 0.05),
                );
              },
              childCount: _filtered.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _SessionListTile extends StatelessWidget {
  final Session session;
  final VoidCallback onTap;

  const _SessionListTile({required this.session, required this.onTap});

  Color _accentColor() {
    switch (session.gradient) {
      case 'sage':
        return AppTheme.sage;
      case 'gold':
        return AppTheme.gold;
      case 'rose':
        return AppTheme.rose;
      default:
        return AppTheme.lavender;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.self_improvement_rounded, color: accent, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(
                    '${session.instructor} · ${session.durationMin} min',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.play_arrow_rounded, color: accent, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
