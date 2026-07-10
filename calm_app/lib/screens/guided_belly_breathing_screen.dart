import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

// ── Guided Cue Model ──────────────────────────────────────────────────────────

class GuidedCue {
  final int startSec; // when to show this cue
  final int endSec; // when it disappears
  final String text; // guidance text
  final BreathAction action; // what the circle does

  const GuidedCue({
    required this.startSec,
    required this.endSec,
    required this.text,
    required this.action,
  });
}

enum BreathAction { idle, inhale, exhale, hold, notice }

// ── Full Guided Script (from transcript) ─────────────────────────────────────

const List<GuidedCue> _cues = [
  GuidedCue(
    startSec: 0,
    endSec: 8,
    text: 'We breathe in and out thousands of times each day without thinking about it.',
    action: BreathAction.idle,
  ),
  GuidedCue(
    startSec: 8,
    endSec: 18,
    text: 'Paying attention to your breathing in stressful moments can quiet the mind and relax the body.',
    action: BreathAction.idle,
  ),
  GuidedCue(
    startSec: 18,
    endSec: 35,
    text: 'Belly breathing reduces activity in the part of our brain that senses fear, anger and frustration.',
    action: BreathAction.idle,
  ),
  GuidedCue(
    startSec: 35,
    endSec: 59,
    text: 'It can be done anytime, anywhere — even in public. Let\'s get started.',
    action: BreathAction.idle,
  ),
  GuidedCue(
    startSec: 59,
    endSec: 77,
    text: 'Begin by getting comfortable where you are — standing or sitting.',
    action: BreathAction.notice,
  ),
  GuidedCue(
    startSec: 77,
    endSec: 96,
    text: 'Feel the weight of your body in the chair, or through your feet on the floor.',
    action: BreathAction.notice,
  ),
  GuidedCue(
    startSec: 96,
    endSec: 110,
    text: 'Start to bring your attention to your breath.',
    action: BreathAction.notice,
  ),
  GuidedCue(
    startSec: 110,
    endSec: 116,
    text: 'Breathe in through the nose...',
    action: BreathAction.inhale,
  ),
  GuidedCue(
    startSec: 116,
    endSec: 125,
    text: 'And out through the mouth.',
    action: BreathAction.exhale,
  ),
  GuidedCue(
    startSec: 125,
    endSec: 139,
    text: 'Take a few deep breaths — in through the nose...',
    action: BreathAction.inhale,
  ),
  GuidedCue(
    startSec: 139,
    endSec: 153,
    text: '...and out through the mouth.',
    action: BreathAction.exhale,
  ),
  GuidedCue(
    startSec: 153,
    endSec: 170,
    text: 'Find the natural rhythm of your breath.',
    action: BreathAction.notice,
  ),
  GuidedCue(
    startSec: 170,
    endSec: 196,
    text: 'Notice where you feel it in your body.',
    action: BreathAction.notice,
  ),
  GuidedCue(
    startSec: 196,
    endSec: 220,
    text: 'Continue to breathe in through the nose...',
    action: BreathAction.inhale,
  ),
  GuidedCue(
    startSec: 220,
    endSec: 240,
    text: '...and out through the mouth.',
    action: BreathAction.exhale,
  ),
  GuidedCue(
    startSec: 240,
    endSec: 267,
    text: 'Close your eyes if you\'re comfortable, or gaze softly downward.',
    action: BreathAction.notice,
  ),
  GuidedCue(
    startSec: 267,
    endSec: 296,
    text: 'Relax.',
    action: BreathAction.exhale,
  ),
  GuidedCue(
    startSec: 296,
    endSec: 319,
    text: 'As you breathe in through your nose, feel your belly fill with air.',
    action: BreathAction.inhale,
  ),
  GuidedCue(
    startSec: 319,
    endSec: 353,
    text: 'Maybe put your hands on your belly and notice the rise and fall as you breathe.',
    action: BreathAction.notice,
  ),
  GuidedCue(
    startSec: 353,
    endSec: 390,
    text: 'Continue belly breathing and feel your body relax.',
    action: BreathAction.exhale,
  ),
  GuidedCue(
    startSec: 390,
    endSec: 419,
    text: 'It\'s okay if thoughts come into your mind. Let them come... and let them go.',
    action: BreathAction.notice,
  ),
  GuidedCue(
    startSec: 419,
    endSec: 447,
    text: 'Just return to following the breath.',
    action: BreathAction.inhale,
  ),
  GuidedCue(
    startSec: 447,
    endSec: 480,
    text: 'If it helps, say to yourself "belly" when you breathe in...',
    action: BreathAction.inhale,
  ),
  GuidedCue(
    startSec: 480,
    endSec: 507,
    text: '...and "breath" when you breathe out.',
    action: BreathAction.exhale,
  ),
  GuidedCue(
    startSec: 507,
    endSec: 547,
    text: 'Keep your attention on your breath for the next 60 seconds...',
    action: BreathAction.notice,
  ),
  GuidedCue(
    startSec: 547,
    endSec: 570,
    text: 'Slowly breathing in through your nose...',
    action: BreathAction.inhale,
  ),
  GuidedCue(
    startSec: 570,
    endSec: 600,
    text: '...and out through your mouth.',
    action: BreathAction.exhale,
  ),
  GuidedCue(
    startSec: 600,
    endSec: 644,
    text: 'Following the pattern of your breath. Noticing the rise...',
    action: BreathAction.inhale,
  ),
  GuidedCue(
    startSec: 644,
    endSec: 684,
    text: '...and the fall of your belly, as you breathe in and breathe out.',
    action: BreathAction.exhale,
  ),
  GuidedCue(
    startSec: 684,
    endSec: 730,
    text: 'Breathe...',
    action: BreathAction.inhale,
  ),
  GuidedCue(
    startSec: 730,
    endSec: 769,
    text: 'Now take a couple more breaths.',
    action: BreathAction.notice,
  ),
  GuidedCue(
    startSec: 769,
    endSec: 503,
    text: 'When you are ready, bring your attention back to where you are.',
    action: BreathAction.notice,
  ),
  GuidedCue(
    startSec: 478,
    endSec: 503,
    text: 'Notice how you feel.',
    action: BreathAction.notice,
  ),
  GuidedCue(
    startSec: 503,
    endSec: 513,
    text: 'It\'s okay if it was difficult or if you noticed a lot of thoughts.',
    action: BreathAction.notice,
  ),
];

// Final cues sorted by time
const List<GuidedCue> guidedCues = [
  GuidedCue(startSec: 0, endSec: 8, text: 'We breathe in and out thousands of times each day without thinking about it.', action: BreathAction.idle),
  GuidedCue(startSec: 8, endSec: 18, text: 'Paying attention to your breathing can quiet the mind and relax the body.', action: BreathAction.idle),
  GuidedCue(startSec: 18, endSec: 35, text: 'Belly breathing reduces activity in the part of our brain that senses fear and frustration.', action: BreathAction.idle),
  GuidedCue(startSec: 35, endSec: 59, text: 'It can be done anytime, anywhere — even in public. Let\'s get started.', action: BreathAction.idle),
  GuidedCue(startSec: 59, endSec: 77, text: 'Begin by getting comfortable where you are — standing or sitting.', action: BreathAction.notice),
  GuidedCue(startSec: 77, endSec: 96, text: 'Feel the weight of your body in the chair, or through your feet on the floor.', action: BreathAction.notice),
  GuidedCue(startSec: 96, endSec: 110, text: 'Start to bring your attention to your breath...', action: BreathAction.notice),
  GuidedCue(startSec: 110, endSec: 120, text: 'Breathe in through the nose ↑', action: BreathAction.inhale),
  GuidedCue(startSec: 120, endSec: 130, text: 'And out through the mouth ↓', action: BreathAction.exhale),
  GuidedCue(startSec: 130, endSec: 145, text: 'In through the nose... ↑', action: BreathAction.inhale),
  GuidedCue(startSec: 145, endSec: 160, text: 'Out through the mouth... ↓', action: BreathAction.exhale),
  GuidedCue(startSec: 160, endSec: 180, text: 'Find the natural rhythm of your breath.', action: BreathAction.notice),
  GuidedCue(startSec: 180, endSec: 200, text: 'Notice where you feel it in your body.', action: BreathAction.notice),
  GuidedCue(startSec: 200, endSec: 215, text: 'Breathe in through the nose ↑', action: BreathAction.inhale),
  GuidedCue(startSec: 215, endSec: 230, text: 'Out through the mouth ↓', action: BreathAction.exhale),
  GuidedCue(startSec: 230, endSec: 260, text: 'Close your eyes if comfortable, or gaze softly downward.', action: BreathAction.notice),
  GuidedCue(startSec: 260, endSec: 280, text: 'Relax...', action: BreathAction.exhale),
  GuidedCue(startSec: 280, endSec: 296, text: 'Breathe in through your nose — feel your belly fill with air ↑', action: BreathAction.inhale),
  GuidedCue(startSec: 296, endSec: 315, text: 'Place your hands on your belly. Notice the rise...', action: BreathAction.inhale),
  GuidedCue(startSec: 315, endSec: 340, text: '...and the fall as you breathe ↓', action: BreathAction.exhale),
  GuidedCue(startSec: 340, endSec: 370, text: 'Continue belly breathing and feel your body relax.', action: BreathAction.exhale),
  GuidedCue(startSec: 370, endSec: 400, text: 'It\'s okay if thoughts come. Let them come... and let them go.', action: BreathAction.notice),
  GuidedCue(startSec: 400, endSec: 425, text: 'Just return to following the breath.', action: BreathAction.notice),
  GuidedCue(startSec: 425, endSec: 445, text: 'Say to yourself "belly" as you breathe in ↑', action: BreathAction.inhale),
  GuidedCue(startSec: 445, endSec: 465, text: 'Say "breath" as you breathe out ↓', action: BreathAction.exhale),
  GuidedCue(startSec: 465, endSec: 490, text: 'Keep your attention on your breath...', action: BreathAction.notice),
  GuidedCue(startSec: 490, endSec: 510, text: 'Slowly breathing in through your nose ↑', action: BreathAction.inhale),
  GuidedCue(startSec: 510, endSec: 530, text: 'And out through your mouth ↓', action: BreathAction.exhale),
  GuidedCue(startSec: 530, endSec: 555, text: 'Notice the rise of your belly ↑', action: BreathAction.inhale),
  GuidedCue(startSec: 555, endSec: 580, text: 'And the fall ↓', action: BreathAction.exhale),
  GuidedCue(startSec: 580, endSec: 620, text: 'Breathe...', action: BreathAction.inhale),
  GuidedCue(startSec: 620, endSec: 660, text: '...', action: BreathAction.exhale),
  GuidedCue(startSec: 660, endSec: 700, text: 'Now take a couple more breaths.', action: BreathAction.notice),
  GuidedCue(startSec: 700, endSec: 730, text: 'Breathe in ↑', action: BreathAction.inhale),
  GuidedCue(startSec: 730, endSec: 760, text: 'Breathe out ↓', action: BreathAction.exhale),
  GuidedCue(startSec: 760, endSec: 490, text: 'When you are ready, bring your attention back to where you are.', action: BreathAction.notice),
  GuidedCue(startSec: 478, endSec: 503, text: 'Notice how you feel.', action: BreathAction.notice),
  GuidedCue(startSec: 503, endSec: 515, text: 'It\'s okay if it was difficult — it gets more comfortable with practice.', action: BreathAction.notice),
  GuidedCue(startSec: 513, endSec: 530, text: 'Thank you for practicing belly breathing today. 🙏', action: BreathAction.idle),
];

// ── Main Screen ───────────────────────────────────────────────────────────────

class GuidedBellyBreathingScreen extends StatefulWidget {
  const GuidedBellyBreathingScreen({super.key});

  @override
  State<GuidedBellyBreathingScreen> createState() =>
      _GuidedBellyBreathingScreenState();
}

class _GuidedBellyBreathingScreenState
    extends State<GuidedBellyBreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  Timer? _sessionTimer;
  int _elapsedSec = 0;
  bool _isRunning = false;
  bool _isComplete = false;
  int _currentCueIndex = 0;

  static const int _totalSec = 515; // ~8.5 minutes

  GuidedCue get _currentCue {
    // Find the cue that matches current time
    GuidedCue? active;
    for (final cue in guidedCues) {
      if (_elapsedSec >= cue.startSec && _elapsedSec < cue.endSec) {
        active = cue;
        break;
      }
    }
    return active ??
        const GuidedCue(
          startSec: 0,
          endSec: 1,
          text: 'Breathe...',
          action: BreathAction.notice,
        );
  }

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  void _start() {
    setState(() {
      _isRunning = true;
      _elapsedSec = 0;
      _isComplete = false;
    });
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSec++);
      _updateBreathAnimation();
      if (_elapsedSec >= _totalSec) {
        _complete();
      }
    });
  }

  void _updateBreathAnimation() {
    final action = _currentCue.action;
    switch (action) {
      case BreathAction.inhale:
        if (_breathController.status != AnimationStatus.forward) {
          _breathController.forward();
        }
        break;
      case BreathAction.exhale:
        if (_breathController.status != AnimationStatus.reverse) {
          _breathController.reverse();
        }
        break;
      case BreathAction.hold:
        _breathController.stop();
        break;
      default:
        // Gentle pulse for idle/notice
        if (!_breathController.isAnimating) {
          _breathController.repeat(reverse: true);
        }
        break;
    }
  }

  void _pause() {
    setState(() => _isRunning = false);
    _sessionTimer?.cancel();
    _breathController.stop();
  }

  void _resume() {
    setState(() => _isRunning = true);
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSec++);
      _updateBreathAnimation();
      if (_elapsedSec >= _totalSec) _complete();
    });
  }

  void _complete() {
    _sessionTimer?.cancel();
    _breathController.stop();
    setState(() {
      _isRunning = false;
      _isComplete = true;
    });
  }

  void _restart() {
    _sessionTimer?.cancel();
    _breathController.reset();
    setState(() {
      _elapsedSec = 0;
      _isRunning = false;
      _isComplete = false;
    });
  }

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color _actionColor(BreathAction action) {
    switch (action) {
      case BreathAction.inhale: return AppTheme.sage;
      case BreathAction.exhale: return AppTheme.lavender;
      case BreathAction.hold: return AppTheme.gold;
      case BreathAction.notice: return const Color(0xFF5BA4CF);
      default: return AppTheme.textSecondary;
    }
  }

  String _actionLabel(BreathAction action) {
    switch (action) {
      case BreathAction.inhale: return 'Breathe In';
      case BreathAction.exhale: return 'Breathe Out';
      case BreathAction.hold: return 'Hold';
      case BreathAction.notice: return 'Notice';
      default: return '';
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete) return _buildCompleteScreen(context);

    final cue = _currentCue;
    final accentColor = _actionColor(cue.action);
    final progress = _totalSec == 0 ? 0.0 : _elapsedSec / _totalSec;

    return Scaffold(
      backgroundColor: AppTheme.midnight,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppTheme.textPrimary, size: 20),
                    onPressed: () {
                      _pause();
                      Navigator.pop(context);
                    },
                  ),
                  Column(
                    children: [
                      const Text('Belly Breathing',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      Text('Guided · 8 min',
                          style: TextStyle(
                              color: AppTheme.sage, fontSize: 11)),
                    ],
                  ),
                  // Timer display
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Text(
                      _formatTime(_elapsedSec),
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            // ── Progress Bar ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: AppTheme.divider,
                  valueColor:
                      AlwaysStoppedAnimation(AppTheme.sage),
                  minHeight: 4,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Action Label ───────────────────────────────────────────
            if (_isRunning && cue.action != BreathAction.idle)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Container(
                  key: ValueKey(cue.action),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: accentColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    _actionLabel(cue.action),
                    style: TextStyle(
                        color: accentColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // ── Animated Belly Circle ──────────────────────────────────
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _breathController,
                  builder: (_, __) {
                    final scale = _isRunning
                        ? 0.55 + _breathController.value * 0.45
                        : 0.65 + math.sin(_elapsedSec * 0.5) * 0.05;

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow rings
                        ...List.generate(3, (i) {
                          final ringScale = scale + i * 0.1 + 0.08;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 260 * ringScale,
                            height: 260 * ringScale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: accentColor
                                    .withOpacity(0.07 - i * 0.02),
                                width: 1,
                              ),
                            ),
                          );
                        }),

                        // Main breathing circle
                        Container(
                          width: 240 * scale,
                          height: 240 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                accentColor.withOpacity(0.35),
                                accentColor.withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                            border: Border.all(
                              color: accentColor.withOpacity(0.6),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.25),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Belly icon
                              const Text('🫁',
                                  style: TextStyle(fontSize: 36)),
                              const SizedBox(height: 8),
                              if (_isRunning)
                                AnimatedSwitcher(
                                  duration:
                                      const Duration(milliseconds: 500),
                                  child: Text(
                                    cue.action == BreathAction.inhale
                                        ? 'belly'
                                        : cue.action ==
                                                BreathAction.exhale
                                            ? 'breath'
                                            : '',
                                    key: ValueKey(cue.action),
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // ── Guidance Text ──────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.divider),
              ),
              constraints: const BoxConstraints(minHeight: 80),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: Text(
                    _isRunning
                        ? cue.text
                        : 'Tap Begin to start your guided\nbelly breathing session',
                    key: ValueKey(cue.text),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Controls ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Restart
                GestureDetector(
                  onTap: _restart,
                  child: Container(
                    width: 48, height: 48,
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
                // Play/Pause
                GestureDetector(
                  onTap: _isRunning
                      ? _pause
                      : (_elapsedSec == 0 ? _start : _resume),
                  child: Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.sageGradient,
                      boxShadow: AppTheme.glowSage,
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
                // Skip forward 30s
                GestureDetector(
                  onTap: () => setState(
                      () => _elapsedSec = (_elapsedSec + 30).clamp(0, _totalSec)),
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: const Icon(Icons.forward_30_rounded,
                        color: AppTheme.textSecondary, size: 22),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.midnight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.sageGradient,
                  boxShadow: AppTheme.glowSage,
                ),
                child: const Center(
                    child: Text('🙏', style: TextStyle(fontSize: 44))),
              ).animate().scale(begin: const Offset(0.5, 0.5)).fadeIn(),

              const SizedBox(height: 28),

              Text('Well Done!',
                  style: Theme.of(context).textTheme.displayMedium)
                  .animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 12),

              const Text(
                'You\'ve completed your belly breathing session.\nAs you practice more, it will feel more comfortable and natural.',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.6),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: const Text(
                  '"Belly breathing is a helpful exercise. You can regularly bring calm to your mind and body."',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                      fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(delay: 400.ms),

              const Spacer(),

              SizedBox(
                width: double.infinity, height: 56,
                child: GestureDetector(
                  onTap: _restart,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.sageGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: AppTheme.glowSage,
                    ),
                    child: const Center(
                      child: Text('Practice Again',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text('Return Home',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 14)),
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
