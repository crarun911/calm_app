import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'guided_belly_breathing_screen.dart';

// ── Data Model ────────────────────────────────────────────────────────────────

class BreathingTechnique {
  final String id;
  final String name;
  final String subtitle;
  final String bestFor;
  final String emoji;
  final Color color;
  final List<BreathPhaseConfig> phases;
  final String description;
  final List<String> benefits;
  final List<String> steps;
  final int recommendedCycles;

  const BreathingTechnique({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.bestFor,
    required this.emoji,
    required this.color,
    required this.phases,
    required this.description,
    required this.benefits,
    required this.steps,
    required this.recommendedCycles,
  });
}

class BreathPhaseConfig {
  final String label;
  final int seconds;
  final bool expand;

  const BreathPhaseConfig({
    required this.label,
    required this.seconds,
    required this.expand,
  });
}

// ── All 10 Techniques ─────────────────────────────────────────────────────────

const List<BreathingTechnique> breathingTechniques = [
  BreathingTechnique(
    id: 'diaphragmatic',
    name: 'Belly Breathing',
    subtitle: 'Diaphragmatic Breathing',
    bestFor: 'General relaxation, stress reduction, anxiety',
    emoji: '🌬️',
    color: AppTheme.sage,
    phases: [
      BreathPhaseConfig(label: 'Breathe In', seconds: 4, expand: true),
      BreathPhaseConfig(label: 'Breathe Out', seconds: 4, expand: false),
    ],
    description:
        'Sit or lie comfortably. Place one hand on your chest and the other on your belly. Breathe so your belly rises on inhale and falls on exhale.',
    benefits: [
      'Activates the body\'s relaxation response',
      'Slows the heart rate',
      'Encourages deeper, more efficient breathing',
    ],
    steps: [
      'Sit or lie comfortably',
      'Place one hand on your chest, other on belly',
      'Inhale slowly through your nose — belly rises',
      'Exhale slowly — belly falls',
      'Continue for 5–10 minutes',
    ],
    recommendedCycles: 10,
  ),
  BreathingTechnique(
    id: 'box',
    name: 'Box Breathing',
    subtitle: '4-4-4-4 Pattern',
    bestFor: 'Focus, calming nerves, high-pressure situations',
    emoji: '⬜',
    color: AppTheme.lavender,
    phases: [
      BreathPhaseConfig(label: 'Breathe In', seconds: 4, expand: true),
      BreathPhaseConfig(label: 'Hold', seconds: 4, expand: true),
      BreathPhaseConfig(label: 'Breathe Out', seconds: 4, expand: false),
      BreathPhaseConfig(label: 'Hold', seconds: 4, expand: false),
    ],
    description:
        'Used by athletes, military personnel and first responders. Equal timing on all four phases creates a mental "box" that anchors attention.',
    benefits: [
      'Improves concentration',
      'Reduces stress quickly',
      'Used by athletes and military',
    ],
    steps: [
      'Inhale for 4 seconds',
      'Hold for 4 seconds',
      'Exhale for 4 seconds',
      'Hold for 4 seconds',
      'Repeat 4–10 cycles',
    ],
    recommendedCycles: 6,
  ),
  BreathingTechnique(
    id: '478',
    name: '4-7-8 Breathing',
    subtitle: 'Sleep & Relaxation',
    bestFor: 'Falling asleep and calming racing thoughts',
    emoji: '🌙',
    color: Color(0xFF9B8EC4),
    phases: [
      BreathPhaseConfig(label: 'Breathe In', seconds: 4, expand: true),
      BreathPhaseConfig(label: 'Hold', seconds: 7, expand: true),
      BreathPhaseConfig(label: 'Breathe Out', seconds: 8, expand: false),
    ],
    description:
        'A powerful technique for sleep onset. The extended hold and exhale activate the parasympathetic nervous system.',
    benefits: [
      'Promotes deep relaxation',
      'May help with sleep onset',
      'Encourages slower breathing',
    ],
    steps: [
      'Inhale through your nose for 4 seconds',
      'Hold your breath for 7 seconds',
      'Exhale slowly through mouth for 8 seconds',
      'Repeat up to 4–8 rounds',
    ],
    recommendedCycles: 4,
  ),
  BreathingTechnique(
    id: 'equal',
    name: 'Equal Breathing',
    subtitle: 'Sama Vritti',
    bestFor: 'Everyday mindfulness',
    emoji: '⚖️',
    color: AppTheme.gold,
    phases: [
      BreathPhaseConfig(label: 'Breathe In', seconds: 4, expand: true),
      BreathPhaseConfig(label: 'Breathe Out', seconds: 4, expand: false),
    ],
    description:
        'Equal inhale and exhale creates a steady, balanced rhythm. Start at 4 counts and gradually increase to 5 or 6 if comfortable.',
    benefits: [
      'Creates a steady breathing rhythm',
      'Helps maintain present-moment awareness',
      'Easy to practice anywhere',
    ],
    steps: [
      'Inhale for 4 counts',
      'Exhale for 4 counts',
      'Gradually increase to 5 or 6 counts',
      'Continue for several minutes',
    ],
    recommendedCycles: 10,
  ),
  BreathingTechnique(
    id: 'extended_exhale',
    name: 'Extended Exhale',
    subtitle: 'Longer Out-Breath',
    bestFor: 'Anxiety, stress, emotional regulation',
    emoji: '🍃',
    color: Color(0xFF4CAF82),
    phases: [
      BreathPhaseConfig(label: 'Breathe In', seconds: 4, expand: true),
      BreathPhaseConfig(label: 'Breathe Out', seconds: 7, expand: false),
    ],
    description:
        'Longer exhalations activate the vagus nerve and parasympathetic system. One of the easiest techniques to use anywhere.',
    benefits: [
      'Encourages a calmer physiological state',
      'Easy to use anywhere',
      'Helps regulate emotions',
    ],
    steps: [
      'Inhale for 4 seconds',
      'Exhale for 6–8 seconds',
      'Continue for several minutes',
    ],
    recommendedCycles: 8,
  ),
  BreathingTechnique(
    id: 'alternate_nostril',
    name: 'Alternate Nostril',
    subtitle: 'Nadi Shodhana',
    bestFor: 'Meditation preparation and mindfulness',
    emoji: '🧘',
    color: AppTheme.rose,
    phases: [
      BreathPhaseConfig(label: 'Inhale Left', seconds: 4, expand: true),
      BreathPhaseConfig(label: 'Hold', seconds: 2, expand: true),
      BreathPhaseConfig(label: 'Exhale Right', seconds: 4, expand: false),
      BreathPhaseConfig(label: 'Inhale Right', seconds: 4, expand: true),
      BreathPhaseConfig(label: 'Hold', seconds: 2, expand: true),
      BreathPhaseConfig(label: 'Exhale Left', seconds: 4, expand: false),
    ],
    description:
        'A yogic breathing practice that alternates between nostrils. Close your right nostril to inhale left, then switch.',
    benefits: [
      'Encourages focused attention',
      'May help you feel more centered',
      'Traditional yogic practice',
    ],
    steps: [
      'Close right nostril, inhale through left',
      'Close left nostril, exhale through right',
      'Inhale through the right',
      'Switch and exhale through the left',
      'Repeat for 5–10 minutes',
    ],
    recommendedCycles: 8,
  ),
  BreathingTechnique(
    id: 'resonance',
    name: 'Resonance Breathing',
    subtitle: 'Coherent Breathing',
    bestFor: 'Long-term stress management',
    emoji: '〰️',
    color: Color(0xFF5BA4CF),
    phases: [
      BreathPhaseConfig(label: 'Breathe In', seconds: 6, expand: true),
      BreathPhaseConfig(label: 'Breathe Out', seconds: 6, expand: false),
    ],
    description:
        'Breathing at approximately 5–6 breaths per minute. This rate is thought to maximise heart rate variability.',
    benefits: [
      'Can improve heart rate variability',
      'Promotes a calm steady pattern',
      'Good for long-term practice',
    ],
    steps: [
      'Breathe about 5–6 breaths per minute',
      'Inhale for 5–6 seconds',
      'Exhale for 5–6 seconds',
      'Continue for 10–20 minutes',
    ],
    recommendedCycles: 10,
  ),
  BreathingTechnique(
    id: 'mindful',
    name: 'Mindful Breathing',
    subtitle: 'Natural Awareness',
    bestFor: 'Meditation and developing awareness',
    emoji: '🌸',
    color: Color(0xFFD4A8C7),
    phases: [
      BreathPhaseConfig(label: 'Breathe In', seconds: 4, expand: true),
      BreathPhaseConfig(label: 'Breathe Out', seconds: 4, expand: false),
    ],
    description:
        'Simply breathe naturally and observe. Notice the sensation of air entering and leaving. When your mind wanders, gently return attention to the breath.',
    benefits: [
      'Strengthens attention',
      'Builds mindfulness',
      'Reduces mental distraction over time',
    ],
    steps: [
      'Breathe naturally',
      'Notice air entering and leaving your nose',
      'Feel the rise and fall of your chest or belly',
      'When mind wanders, gently return to breath',
    ],
    recommendedCycles: 10,
  ),
  BreathingTechnique(
    id: 'pursed_lip',
    name: 'Pursed-Lip Breathing',
    subtitle: 'Controlled Exhale',
    bestFor: 'Feeling short of breath or slowing breathing',
    emoji: '💨',
    color: Color(0xFF7EC8A4),
    phases: [
      BreathPhaseConfig(label: 'Breathe In', seconds: 2, expand: true),
      BreathPhaseConfig(label: 'Breathe Out', seconds: 4, expand: false),
    ],
    description:
        'Inhale through nose, then exhale through pursed lips as if gently blowing out a candle. Slows the breath and can ease shortness of breath.',
    benefits: [
      'Slows breathing effectively',
      'Can make breathing feel easier',
      'Helpful for some lung conditions',
    ],
    steps: [
      'Inhale through your nose for 2 counts',
      'Purse your lips like blowing a candle',
      'Exhale slowly for about 4 counts',
    ],
    recommendedCycles: 10,
  ),
  BreathingTechnique(
    id: 'ujjayi',
    name: 'Ocean Breath',
    subtitle: 'Ujjayi Breathing',
    bestFor: 'Yoga and mindful movement',
    emoji: '🌊',
    color: Color(0xFF4A9BAB),
    phases: [
      BreathPhaseConfig(label: 'Inhale', seconds: 5, expand: true),
      BreathPhaseConfig(label: 'Exhale (Ocean)', seconds: 5, expand: false),
    ],
    description:
        'Inhale through nose, then slightly narrow the back of your throat on exhale to create a soft "ocean wave" sound.',
    benefits: [
      'Encourages concentration',
      'Helps coordinate breath with movement',
      'Creates a calming rhythm',
    ],
    steps: [
      'Inhale through your nose',
      'Slightly narrow the back of your throat',
      'Exhale through nose with soft "ocean" sound',
    ],
    recommendedCycles: 10,
  ),
];

// ── Main Screen ───────────────────────────────────────────────────────────────

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  BreathingTechnique? _selected;

  @override
  Widget build(BuildContext context) {
    if (_selected != null) {
      return _BreathingPlayer(
        technique: _selected!,
        onBack: () => setState(() => _selected = null),
      );
    }
    return _TechniqueList(
      onSelect: (t) => setState(() => _selected = t),
    );
  }
}

// ── Technique List ────────────────────────────────────────────────────────────

class _TechniqueList extends StatelessWidget {
  final ValueChanged<BreathingTechnique> onSelect;
  const _TechniqueList({required this.onSelect});

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
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.textPrimary,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Breathe',
                            style: Theme.of(context).textTheme.headlineLarge),
                        const Text('10 techniques',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Hero banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.sageGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.glowSage,
                ),
                child: const Row(
                  children: [
                    Text('🌬️', style: TextStyle(fontSize: 40)),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Breathing Exercises',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text(
                            'Choose a technique and follow the animated guide',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Guided badge for belly breathing
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.sage.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppTheme.sage.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.record_voice_over_rounded,
                        color: AppTheme.sage, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Belly Breathing has a full guided 8-minute session',
                      style: TextStyle(
                          color: AppTheme.sageLight, fontSize: 12),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 150.ms),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final t = breathingTechniques[i];
                final isGuided = t.id == 'diaphragmatic';
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: _TechniqueCard(
                    technique: t,
                    isGuided: isGuided,
                    onTap: () {
                      if (isGuided) {
                        // Belly Breathing → full guided session
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const GuidedBellyBreathingScreen(),
                          ),
                        );
                      } else {
                        // All others → standard player
                        onSelect(t);
                      }
                    },
                  )
                      .animate(
                          delay: Duration(milliseconds: 150 + i * 60))
                      .fadeIn()
                      .slideY(begin: 0.05),
                );
              },
              childCount: breathingTechniques.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ── Technique Card ────────────────────────────────────────────────────────────

class _TechniqueCard extends StatelessWidget {
  final BreathingTechnique technique;
  final bool isGuided;
  final VoidCallback onTap;

  const _TechniqueCard({
    required this.technique,
    required this.isGuided,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isGuided
                ? AppTheme.sage.withOpacity(0.4)
                : AppTheme.divider,
          ),
        ),
        child: Row(
          children: [
            // Emoji circle
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: technique.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(technique.emoji,
                    style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(technique.name,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
                      if (isGuided) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.sage.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('GUIDED',
                              style: TextStyle(
                                  color: AppTheme.sage,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(technique.subtitle,
                      style: TextStyle(
                          color: technique.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                    technique.bestFor,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Phase timing / guided icon
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: technique.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isGuided ? '8 min' : '${technique.phases.length} phases',
                    style: TextStyle(
                        color: technique.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isGuided
                      ? 'guided'
                      : technique.phases.map((p) => '${p.seconds}s').join('-'),
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Breathing Player ──────────────────────────────────────────────────────────

class _BreathingPlayer extends StatefulWidget {
  final BreathingTechnique technique;
  final VoidCallback onBack;
  const _BreathingPlayer({required this.technique, required this.onBack});

  @override
  State<_BreathingPlayer> createState() => _BreathingPlayerState();
}

class _BreathingPlayerState extends State<_BreathingPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isRunning = false;
  int _phaseIndex = 0;
  int _countdown = 0;
  int _cycleCount = 0;
  Timer? _timer;
  bool _showInfo = false;

  BreathPhaseConfig get _currentPhase =>
      widget.technique.phases[_phaseIndex];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _countdown = widget.technique.phases[0].seconds;
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _isRunning = true;
      _phaseIndex = 0;
      _cycleCount = 0;
    });
    _runPhase();
  }

  void _pause() {
    setState(() => _isRunning = false);
    _controller.stop();
    _timer?.cancel();
  }

  void _reset() {
    _pause();
    setState(() {
      _phaseIndex = 0;
      _cycleCount = 0;
      _countdown = widget.technique.phases[0].seconds;
    });
    _controller.reset();
  }

  void _runPhase() {
    final phase = _currentPhase;
    final duration = phase.seconds;
    setState(() => _countdown = duration);

    _controller.duration = Duration(seconds: duration);
    if (phase.expand) {
      _controller.forward(
          from: _controller.value < 0.5 ? 0 : _controller.value);
    } else {
      _controller.reverse(
          from: _controller.value > 0.5 ? 1 : _controller.value);
    }

    int remaining = duration;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      remaining--;
      if (mounted) setState(() => _countdown = remaining);
      if (remaining <= 0) {
        t.cancel();
        if (_isRunning) _nextPhase();
      }
    });
  }

  void _nextPhase() {
    final nextIndex = (_phaseIndex + 1) % widget.technique.phases.length;
    if (nextIndex == 0) {
      setState(() => _cycleCount++);
      if (_cycleCount >= widget.technique.recommendedCycles) {
        _pause();
        _showCompleteDialog();
        return;
      }
    }
    setState(() => _phaseIndex = nextIndex);
    _runPhase();
  }

  void _showCompleteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Session Complete! 🎉',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'You completed ${widget.technique.recommendedCycles} cycles of ${widget.technique.name}.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _reset();
            },
            child: Text('Again',
                style: TextStyle(color: widget.technique.color)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onBack();
            },
            child: const Text('Done',
                style: TextStyle(color: AppTheme.sage)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.technique;

    return Scaffold(
      backgroundColor: AppTheme.midnight,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppTheme.textPrimary, size: 20),
                    onPressed: () {
                      _reset();
                      widget.onBack();
                    },
                  ),
                  Column(
                    children: [
                      Text(t.name,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      Text(t.subtitle,
                          style:
                              TextStyle(color: t.color, fontSize: 11)),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      _showInfo
                          ? Icons.close_rounded
                          : Icons.info_outline_rounded,
                      color: AppTheme.textSecondary,
                      size: 22,
                    ),
                    onPressed: () =>
                        setState(() => _showInfo = !_showInfo),
                  ),
                ],
              ),
            ),

            // ── Info Panel ────────────────────────────────────────────
            if (_showInfo)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoSection(
                          title: 'Best For',
                          content: t.bestFor,
                          color: t.color),
                      const SizedBox(height: 16),
                      _InfoSection(
                          title: 'How To Do It',
                          steps: t.steps,
                          color: t.color),
                      const SizedBox(height: 16),
                      _InfoSection(
                          title: 'Benefits',
                          bullets: t.benefits,
                          color: t.color),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _showInfo = false);
                            _start();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                t.color,
                                t.color.withOpacity(0.7)
                              ]),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text('Start Practice',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // ── Cycle counter ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Cycle $_cycleCount / ${t.recommendedCycles}',
                  style: TextStyle(
                      color: t.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ),

              // ── Animated Circle ──────────────────────────────────
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (_, __) {
                      final scale = 0.5 + _controller.value * 0.5;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          ...List.generate(3, (i) {
                            final ringScale = scale + i * 0.12 + 0.05;
                            return Container(
                              width: 260 * ringScale,
                              height: 260 * ringScale,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: t.color
                                      .withOpacity(0.08 - i * 0.02),
                                  width: 1,
                                ),
                              ),
                            );
                          }),
                          Container(
                            width: 220 * scale,
                            height: 220 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  t.color.withOpacity(0.4),
                                  t.color.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                              ),
                              border: Border.all(
                                  color: t.color.withOpacity(0.6),
                                  width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: t.color.withOpacity(0.25),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(t.emoji,
                                    style:
                                        const TextStyle(fontSize: 32)),
                                const SizedBox(height: 8),
                                AnimatedSwitcher(
                                  duration: const Duration(
                                      milliseconds: 400),
                                  child: Text(
                                    _isRunning
                                        ? _currentPhase.label
                                        : 'Ready',
                                    key: ValueKey(
                                        '$_isRunning$_phaseIndex'),
                                    style: TextStyle(
                                        color: t.color,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                if (_isRunning) ...[
                                  const SizedBox(height: 4),
                                  AnimatedSwitcher(
                                    duration: const Duration(
                                        milliseconds: 200),
                                    child: Text(
                                      '$_countdown',
                                      key: ValueKey(_countdown),
                                      style: TextStyle(
                                          color: t.color,
                                          fontSize: 42,
                                          fontWeight: FontWeight.w200),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // ── Phase indicators ─────────────────────────────────
              if (_isRunning)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(t.phases.length, (i) {
                      final isActive = i == _phaseIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? t.color : AppTheme.divider,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),

              // ── Phase labels ─────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: t.phases
                      .asMap()
                      .entries
                      .map((e) => _PhaseChip(
                            label: e.value.label,
                            seconds: e.value.seconds,
                            isActive: _isRunning && e.key == _phaseIndex,
                            color: t.color,
                          ))
                      .toList(),
                ),
              ),

              // ── Controls ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _reset,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: const Icon(Icons.refresh_rounded,
                            color: AppTheme.textSecondary, size: 22),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: _isRunning ? _pause : _start,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                              colors: [t.color, t.color.withOpacity(0.7)]),
                          boxShadow: [
                            BoxShadow(
                                color: t.color.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 4),
                          ],
                        ),
                        child: Icon(
                          _isRunning
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showInfo = !_showInfo),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: const Icon(Icons.info_outline_rounded,
                            color: AppTheme.textSecondary, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Phase Chip ────────────────────────────────────────────────────────────────

class _PhaseChip extends StatelessWidget {
  final String label;
  final int seconds;
  final bool isActive;
  final Color color;

  const _PhaseChip({
    required this.label,
    required this.seconds,
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.15) : AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isActive ? color.withOpacity(0.4) : AppTheme.divider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  color: isActive ? color : AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w400)),
          Text('${seconds}s',
              style: TextStyle(
                  color: isActive ? color : AppTheme.textMuted,
                  fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Info Section ──────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  final String title;
  final String? content;
  final List<String>? steps;
  final List<String>? bullets;
  final Color color;

  const _InfoSection({
    required this.title,
    this.content,
    this.steps,
    this.bullets,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 10),
          if (content != null)
            Text(content!,
                style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.5)),
          if (steps != null)
            ...steps!.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text('${e.key + 1}',
                              style: TextStyle(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(e.value,
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                height: 1.4)),
                      ),
                    ],
                  ),
                )),
          if (bullets != null)
            ...bullets!.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(b,
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                height: 1.4)),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
