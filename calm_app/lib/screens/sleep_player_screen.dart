import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';

// This is a special audio player for sleep — dims screen progressively
class SleepPlayerScreen extends StatefulWidget {
  final Session session;
  final VoidCallback? onComplete;

  const SleepPlayerScreen({
    super.key,
    required this.session,
    this.onComplete,
  });

  @override
  State<SleepPlayerScreen> createState() => _SleepPlayerScreenState();
}

class _SleepPlayerScreenState extends State<SleepPlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AudioPlayer _audioPlayer;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _brightness = 1.0; // 1.0 = full, 0.0 = black
  bool _screenDimmed = false;
  bool _autoDim = true; // toggle auto-dim
  Timer? _dimTimer;
  int? _sleepTimerMin;
  Duration? _sleepTargetPosition;
  Duration? _sleepStartPosition;
  bool _isFading = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setAsset(widget.session.audioPath);

      _audioPlayer.durationStream.listen((d) {
        if (d != null && mounted) setState(() => _duration = d);
      });

      _audioPlayer.positionStream.listen((pos) {
        if (!mounted) return;
        setState(() => _position = pos);

        // Auto dim screen after 2 minutes of playing
        if (_autoDim && _isPlaying && pos.inSeconds > 120 && !_screenDimmed) {
          _startDimming();
        }

        // Sleep timer check
        if (_sleepTargetPosition != null) {
          final remaining = _sleepTargetPosition! - pos;
          if (remaining.inSeconds <= 0) {
            _audioPlayer.setVolume(1.0);
            _audioPlayer.pause();
            _clearSleepTimer();
          } else if (remaining.inSeconds <= 30) {
            setState(() => _isFading = true);
            final volume = (remaining.inSeconds / 30.0).clamp(0.0, 1.0);
            _audioPlayer.setVolume(volume);
          }
        }
      });

      _audioPlayer.playerStateStream.listen((state) {
        if (!mounted) return;
        setState(() => _isPlaying = state.playing);
        if (state.processingState == ProcessingState.completed) {
          _onComplete();
        }
      });
    } catch (e) {
      debugPrint('Audio error: $e');
    }
  }

  void _startDimming() {
    setState(() => _screenDimmed = true);
    // Gradually dim over 30 seconds
    const steps = 30;
    int step = 0;
    _dimTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      step++;
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _brightness = (1.0 - step / steps).clamp(0.05, 1.0);
      });
      if (step >= steps) t.cancel();
    });
  }

  void _wakeScreen() {
    _dimTimer?.cancel();
    setState(() {
      _brightness = 1.0;
      _screenDimmed = false;
    });
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  void _setSleepTimer(int? minutes) {
    if (minutes == null) {
      _clearSleepTimer();
      _audioPlayer.setVolume(1.0);
      return;
    }
    final target = _position + Duration(minutes: minutes);
    setState(() {
      _sleepTimerMin = minutes;
      _sleepTargetPosition = target;
      _sleepStartPosition = _position;
      _isFading = false;
    });
    _audioPlayer.setVolume(1.0);
  }

  void _clearSleepTimer() {
    if (mounted) {
      setState(() {
        _sleepTimerMin = null;
        _sleepTargetPosition = null;
        _sleepStartPosition = null;
        _isFading = false;
      });
    }
  }

  int get _remainingSec {
    if (_sleepTargetPosition == null) return 0;
    return (_sleepTargetPosition! - _position).inSeconds.clamp(0, 999999);
  }

  String _formatCountdown(int s) {
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration d) {
    return '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  double get _progress {
    if (_duration.inMilliseconds == 0) return 0;
    return (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
  }

  void _onComplete() {
    context.read<AppState>().completeSession();
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dimTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tap anywhere to wake screen
      onTap: _screenDimmed ? _wakeScreen : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: Color.fromRGBO(
          (AppTheme.midnight.red * _brightness).round(),
          (AppTheme.midnight.green * _brightness).round(),
          (AppTheme.midnight.blue * _brightness).round(),
          1.0,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _brightness,
              child: Column(
                children: [
                  // ── Top Bar ────────────────────────────────────────
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
                        // Auto-dim toggle
                        IconButton(
                          icon: Icon(
                            _autoDim
                                ? Icons.brightness_2_rounded
                                : Icons.brightness_high_rounded,
                            color: _autoDim
                                ? AppTheme.lavender
                                : AppTheme.textSecondary,
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() => _autoDim = !_autoDim);
                            if (!_autoDim) _wakeScreen();
                          },
                        ),
                      ],
                    ),
                  ),

                  // ── Sleep timer banner ────────────────────────────
                  if (_sleepTargetPosition != null)
                    Container(
                      margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isFading
                            ? AppTheme.rose.withOpacity(0.15)
                            : AppTheme.lavender.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isFading
                              ? AppTheme.rose.withOpacity(0.4)
                              : AppTheme.lavender.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isFading
                                ? Icons.volume_down_rounded
                                : Icons.bedtime_rounded,
                            color: _isFading
                                ? AppTheme.rose
                                : AppTheme.lavenderLight,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isFading
                                ? 'Fading... ${_formatCountdown(_remainingSec)}'
                                : 'Sleep timer: ${_formatCountdown(_remainingSec)}',
                            style: TextStyle(
                              color: _isFading
                                  ? AppTheme.rose
                                  : AppTheme.lavenderLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              _clearSleepTimer();
                              _audioPlayer.setVolume(1.0);
                            },
                            child: Icon(Icons.close_rounded,
                                color: _isFading
                                    ? AppTheme.rose
                                    : AppTheme.lavenderLight,
                                size: 14),
                          ),
                        ],
                      ),
                    ),

                  // ── Screen dim indicator ──────────────────────────
                  if (_screenDimmed)
                    Container(
                      margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.lavender.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.lavender.withOpacity(0.2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app_rounded,
                              color: AppTheme.lavenderLight, size: 14),
                          SizedBox(width: 6),
                          Text('Tap to wake screen',
                              style: TextStyle(
                                  color: AppTheme.lavenderLight,
                                  fontSize: 12)),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ── Artwork ────────────────────────────────────────
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (_, __) {
                          final scale = 0.8 + _pulseController.value * 0.2;
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              ...List.generate(3, (i) {
                                final v = (_pulseController.value +
                                        i * 0.3) %
                                    1.0;
                                return Container(
                                  width: 200 + v * 60,
                                  height: 200 + v * 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.lavender
                                          .withOpacity(0.06 + (1 - v) * 0.04),
                                      width: 1,
                                    ),
                                  ),
                                );
                              }),
                              Container(
                                width: 180 * scale,
                                height: 180 * scale,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppTheme.lavender.withOpacity(0.3),
                                      AppTheme.lavender.withOpacity(0.05),
                                      Colors.transparent,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppTheme.lavender.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('🌙',
                                        style: TextStyle(fontSize: 40)),
                                    const SizedBox(height: 8),
                                    Text(widget.session.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300,
                                        ),
                                        textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  // ── Info ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Text(widget.session.title,
                            style: Theme.of(context).textTheme.displayMedium,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.session.instructor} · ${widget.session.durationMin} min',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Slider ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbColor: AppTheme.lavender,
                            activeTrackColor: AppTheme.lavender,
                            inactiveTrackColor: AppTheme.divider,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            trackHeight: 3,
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 16),
                          ),
                          child: Slider(
                            value: _progress,
                            onChanged: (v) async {
                              final pos = Duration(
                                  milliseconds:
                                      (v * _duration.inMilliseconds).round());
                              await _audioPlayer.seek(pos);
                              if (_sleepTargetPosition != null) {
                                if (pos >= _sleepTargetPosition! ||
                                    (_sleepStartPosition != null &&
                                        pos < _sleepStartPosition!)) {
                                  _clearSleepTimer();
                                  _audioPlayer.setVolume(1.0);
                                }
                              }
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
                                      color: AppTheme.textSecondary,
                                      fontSize: 12)),
                              Text(_formatDuration(_duration),
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Controls ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Sleep timer
                        GestureDetector(
                          onTap: () => _showSleepTimerModal(),
                          child: Column(children: [
                            Icon(Icons.bedtime_outlined,
                                color: _sleepTargetPosition != null
                                    ? AppTheme.lavender
                                    : AppTheme.textSecondary,
                                size: 26),
                            const SizedBox(height: 4),
                            Text(
                              _sleepTimerMin != null
                                  ? '$_sleepTimerMin min'
                                  : 'Timer',
                              style: TextStyle(
                                  color: _sleepTargetPosition != null
                                      ? AppTheme.lavender
                                      : AppTheme.textSecondary,
                                  fontSize: 10),
                            ),
                          ]),
                        ),
                        // Rewind
                        IconButton(
                          icon: const Icon(Icons.replay_10_rounded,
                              color: AppTheme.textPrimary, size: 30),
                          onPressed: () async {
                            final newPos = _position - const Duration(seconds: 10);
                            await _audioPlayer.seek(
                                newPos.isNegative ? Duration.zero : newPos);
                          },
                        ),
                        // Play/Pause
                        GestureDetector(
                          onTap: _togglePlay,
                          child: Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [
                                AppTheme.lavender,
                                AppTheme.lavender.withOpacity(0.7)
                              ]),
                              boxShadow: [
                                BoxShadow(
                                    color: AppTheme.lavender.withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 4)
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
                        // Forward
                        IconButton(
                          icon: const Icon(Icons.forward_10_rounded,
                              color: AppTheme.textPrimary, size: 30),
                          onPressed: () async {
                            final newPos = _position + const Duration(seconds: 10);
                            await _audioPlayer.seek(newPos);
                          },
                        ),
                        // Done
                        GestureDetector(
                          onTap: _onComplete,
                          child: const Column(children: [
                            Icon(Icons.check_circle_outline_rounded,
                                color: AppTheme.sage, size: 26),
                            SizedBox(height: 4),
                            Text('Done',
                                style: TextStyle(
                                    color: AppTheme.sage, fontSize: 10)),
                          ]),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSleepTimerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
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
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Sleep Timer',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Audio fades in the last 30 seconds',
                style:
                    TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            ...([15, 30, 45, 60, null]).map((min) {
              final isSelected = _sleepTimerMin == min;
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _setSleepTimer(min);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.lavender.withOpacity(0.15)
                        : AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: isSelected
                            ? AppTheme.lavender.withOpacity(0.5)
                            : AppTheme.divider),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(min == null ? '🔕  Off' : '🌙  $min minutes',
                          style: TextStyle(
                              color: isSelected
                                  ? AppTheme.lavenderLight
                                  : AppTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 15)),
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
      ),
    );
  }
}
