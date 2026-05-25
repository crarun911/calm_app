import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';

class AudioPlayerScreen extends StatefulWidget {
  final Session session;
  final VoidCallback? onComplete;

  const AudioPlayerScreen({
    super.key,
    required this.session,
    this.onComplete,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  int? _sleepTimerMin;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setAsset(widget.session.audioPath);

      // Listen to duration
      _audioPlayer.durationStream.listen((d) {
        if (d != null && mounted) {
          setState(() => _duration = d);
        }
      });

      // Listen to position
      _audioPlayer.positionStream.listen((p) {
        if (mounted) {
          setState(() => _position = p);
        }
      });

      // Listen to player state
      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() => _isPlaying = state.playing);
          if (state.playing) {
            _rotateController.repeat();
          } else {
            _rotateController.stop();
          }
          // Auto complete when track ends
          if (state.processingState == ProcessingState.completed) {
            _onSessionComplete();
          }
        }
      });
    } catch (e) {
      debugPrint('Audio init error: $e');
    }
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  void _seekRelative(int seconds) async {
    final newPos = _position + Duration(seconds: seconds);
    await _audioPlayer.seek(newPos.isNegative ? Duration.zero : newPos);
  }

  void _onSessionComplete() {
    context.read<AppState>().completeSession();
    widget.onComplete?.call();
  }

  void _showSleepTimerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SleepTimerModal(
        selected: _sleepTimerMin,
        onSelect: (min) async {
          setState(() => _sleepTimerMin = min);
          Navigator.pop(context);
          if (min != null) {
            await Future.delayed(Duration(minutes: min));
            if (mounted) await _audioPlayer.pause();
          }
        },
      ),
    );
  }

  double get _progress {
    if (_duration.inMilliseconds == 0) return 0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  String _formatDuration(Duration d) {
    final min = d.inMinutes.toString().padLeft(2, '0');
    final sec = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Gradient _sessionGradient() {
    switch (widget.session.gradient) {
      case 'sage': return AppTheme.sageGradient;
      case 'gold': return AppTheme.goldGradient;
      case 'rose': return AppTheme.roseGradient;
      case 'sleep': return AppTheme.sleepGradient;
      default: return const LinearGradient(colors: [AppTheme.lavender, Color(0xFF6B5CA5)]);
    }
  }

  Color _accentColor() {
    switch (widget.session.gradient) {
      case 'sage': return AppTheme.sage;
      case 'gold': return AppTheme.gold;
      case 'rose': return AppTheme.rose;
      default: return AppTheme.lavender;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor();

    return Scaffold(
      backgroundColor: AppTheme.midnight,
      body: Stack(
        children: [
          Positioned(
            top: -80, left: -80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: 100, right: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // ── Top Bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppTheme.textPrimary, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        widget.session.category.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz_rounded,
                            color: AppTheme.textPrimary, size: 26),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Animated Artwork ──────────────────────────────────
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            ...[140.0, 120.0, 100.0].asMap().entries.map((e) {
                              final delay = e.key * 0.3;
                              final val = (_pulseController.value + delay) % 1.0;
                              return Container(
                                width: e.value + val * 40,
                                height: e.value + val * 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: accent.withOpacity(0.08 + (1 - val) * 0.05),
                                    width: 1,
                                  ),
                                ),
                              );
                            }),
                            AnimatedBuilder(
                              animation: _rotateController,
                              builder: (_, child) => Transform.rotate(
                                angle: _rotateController.value * 2 * math.pi,
                                child: child,
                              ),
                              child: Container(
                                width: 220, height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: _sessionGradient(),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accent.withOpacity(0.3),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ...List.generate(6, (i) {
                                      final angle = i * math.pi / 3;
                                      return Positioned(
                                        left: 110 + math.cos(angle) * 60,
                                        top: 110 + math.sin(angle) * 60,
                                        child: Container(
                                          width: 30, height: 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withOpacity(0.05),
                                          ),
                                        ),
                                      );
                                    }),
                                    Container(
                                      width: 60, height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppTheme.midnight.withOpacity(0.8),
                                      ),
                                      child: Icon(
                                        Icons.self_improvement_rounded,
                                        color: accent, size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // ── Session Info ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(widget.session.title,
                          style: Theme.of(context).textTheme.displayMedium,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      Text(
                        '${widget.session.instructor} · ${widget.session.durationMin} min',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Progress Slider ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbColor: accent,
                          activeTrackColor: accent,
                          inactiveTrackColor: AppTheme.divider,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          trackHeight: 3,
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                        ),
                        child: Slider(
                          value: _progress.clamp(0.0, 1.0),
                          onChanged: (v) async {
                            final pos = Duration(
                              milliseconds: (v * _duration.inMilliseconds).round(),
                            );
                            await _audioPlayer.seek(pos);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(_position),
                                style: const TextStyle(
                                    color: AppTheme.textSecondary, fontSize: 12)),
                            Text(_formatDuration(_duration),
                                style: const TextStyle(
                                    color: AppTheme.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Controls ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Sleep timer
                      GestureDetector(
                        onTap: _showSleepTimerModal,
                        child: Column(
                          children: [
                            Icon(Icons.bedtime_outlined,
                                color: _sleepTimerMin != null
                                    ? accent
                                    : AppTheme.textSecondary,
                                size: 26),
                            const SizedBox(height: 4),
                            Text(
                              _sleepTimerMin != null
                                  ? '$_sleepTimerMin min'
                                  : 'Timer',
                              style: TextStyle(
                                color: _sleepTimerMin != null
                                    ? accent
                                    : AppTheme.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Rewind 10s
                      IconButton(
                        icon: const Icon(Icons.replay_10_rounded,
                            color: AppTheme.textPrimary, size: 30),
                        onPressed: () => _seekRelative(-10),
                      ),
                      // Play/Pause
                      GestureDetector(
                        onTap: _togglePlay,
                        child: Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [accent, accent.withOpacity(0.7)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ),
                      // Forward 10s
                      IconButton(
                        icon: const Icon(Icons.forward_10_rounded,
                            color: AppTheme.textPrimary, size: 30),
                        onPressed: () => _seekRelative(10),
                      ),
                      // Complete session
                      GestureDetector(
                        onTap: _onSessionComplete,
                        child: const Column(
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                color: AppTheme.sage, size: 26),
                            SizedBox(height: 4),
                            Text('Done',
                                style: TextStyle(
                                    color: AppTheme.sage, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sleep Timer Modal ─────────────────────────────────────────────────────────

class _SleepTimerModal extends StatelessWidget {
  final int? selected;
  final ValueChanged<int?> onSelect;

  const _SleepTimerModal({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Sleep Timer',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Audio will fade out after the selected time',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),
          ...([15, 30, 45, 60, null]).map((min) {
            final isSelected = selected == min;
            return GestureDetector(
              onTap: () => onSelect(min),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.lavender.withOpacity(0.15)
                      : AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.lavender.withOpacity(0.5)
                        : AppTheme.divider,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      min == null ? 'Off' : '$min minutes',
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.lavenderLight
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_rounded,
                          color: AppTheme.lavenderLight, size: 18),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
