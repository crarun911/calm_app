import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../widgets/common_widgets.dart';
import 'audio_player_screen.dart';

class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.midnight,
      body: Stack(
        children: [
          // Night sky gradient backdrop
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF08091A), Color(0xFF0D1117)],
              ),
            ),
          ),
          // Stars
          ...List.generate(30, (i) {
            final x = (i * 43.7) % 400;
            final y = (i * 31.3) % 450;
            final size = (i % 2 == 0 ? 2.0 : 1.5);
            return Positioned(
              left: x,
              top: y,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.4 + (i % 5) * 0.1),
                ),
              ),
            );
          }),

          CustomScrollView(
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
                              color: AppTheme.cardSurface.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.divider),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: AppTheme.textPrimary, size: 16),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text('Sleep', style: Theme.of(context).textTheme.headlineLarge),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ── Moon visual ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.lavenderLight,
                          AppTheme.lavender,
                          AppTheme.lavender.withOpacity(0.3),
                        ],
                        stops: const [0.3, 0.7, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.lavender.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🌙', style: TextStyle(fontSize: 42)),
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.7, 0.7)),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // ── Sleep Stories ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const SectionHeader(title: 'Sleep Stories'),
                ).animate().fadeIn(delay: 300.ms),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final s = sleepSessions[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                      child: GradientSessionCard(
                        session: s,
                        large: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AudioPlayerScreen(session: s),
                          ),
                        ),
                      ).animate(delay: Duration(milliseconds: 350 + i * 80)).fadeIn().slideY(begin: 0.05),
                    );
                  },
                  childCount: sleepSessions.length,
                ),
              ),

              // ── Ambient Sounds ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: const SectionHeader(title: 'Ambient Sounds'),
                ).animate().fadeIn(delay: 500.ms),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: ambientSounds.length,
                    itemBuilder: (_, i) {
                      final sound = ambientSounds[i];
                      return _AmbientTile(
                        name: sound['name'] as String,
                        emoji: sound['emoji'] as String,
                      ).animate(delay: Duration(milliseconds: 550 + i * 60)).fadeIn().scale(begin: const Offset(0.8, 0.8));
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmbientTile extends StatefulWidget {
  final String name;
  final String emoji;
  const _AmbientTile({required this.name, required this.emoji});

  @override
  State<_AmbientTile> createState() => _AmbientTileState();
}

class _AmbientTileState extends State<_AmbientTile> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _active = !_active),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _active ? AppTheme.lavender.withOpacity(0.2) : AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _active ? AppTheme.lavender.withOpacity(0.5) : AppTheme.divider,
          ),
          boxShadow: _active
              ? [
                  BoxShadow(
                    color: AppTheme.lavender.withOpacity(0.2),
                    blurRadius: 12,
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              widget.name,
              style: TextStyle(
                color: _active ? AppTheme.lavenderLight : AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: _active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (_active)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.music_note_rounded, color: AppTheme.lavender, size: 12),
              ),
          ],
        ),
      ),
    );
  }
}
