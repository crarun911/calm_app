import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

enum BreathPhase { inhale, hold, exhale, rest }

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isRunning = false;
  BreathPhase _phase = BreathPhase.inhale;
  int _countdown = 4;
  Timer? _phaseTimer;
  int _cycleCount = 0;

  // 4-7-8 breathing: inhale 4s, hold 7s, exhale 8s
  static const _phaseDurations = {
    BreathPhase.inhale: 4,
    BreathPhase.hold: 7,
    BreathPhase.exhale: 8,
    BreathPhase.rest: 1,
  };

  static const _phaseLabels = {
    BreathPhase.inhale: 'Breathe In',
    BreathPhase.hold: 'Hold',
    BreathPhase.exhale: 'Breathe Out',
    BreathPhase.rest: 'Rest',
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
  }

  @override
  void dispose() {
    _controller.dispose();
    _phaseTimer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _isRunning = true;
      _phase = BreathPhase.inhale;
      _countdown = _phaseDurations[BreathPhase.inhale]!;
    });
    _runPhase();
  }

  void _pause() {
    setState(() => _isRunning = false);
    _controller.stop();
    _phaseTimer?.cancel();
  }

  void _runPhase() {
    final duration = _phaseDurations[_phase]!;
    setState(() => _countdown = duration);

    // Animate the circle
    _controller.duration = Duration(seconds: duration);
    if (_phase == BreathPhase.inhale) {
      _controller.forward(from: 0);
    } else if (_phase == BreathPhase.exhale) {
      _controller.reverse(from: 1);
    }

    // Countdown timer
    int remaining = duration;
    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      remaining--;
      if (mounted) setState(() => _countdown = remaining);
      if (remaining <= 0) {
        t.cancel();
        if (_isRunning) _nextPhase();
      }
    });
  }

  void _nextPhase() {
    BreathPhase next;
    switch (_phase) {
      case BreathPhase.inhale:
        next = BreathPhase.hold;
        break;
      case BreathPhase.hold:
        next = BreathPhase.exhale;
        break;
      case BreathPhase.exhale:
        next = BreathPhase.rest;
        setState(() => _cycleCount++);
        break;
      case BreathPhase.rest:
        next = BreathPhase.inhale;
        break;
    }
    setState(() => _phase = next);
    _runPhase();
  }

  Color _phaseColor() {
    switch (_phase) {
      case BreathPhase.inhale:
        return AppTheme.sage;
      case BreathPhase.hold:
        return AppTheme.lavender;
      case BreathPhase.exhale:
        return AppTheme.gold;
      case BreathPhase.rest:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _phaseColor();

    return Scaffold(
      backgroundColor: AppTheme.midnight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _pause();
                      Navigator.pop(context);
                    },
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
                  Text('Breathe', style: Theme.of(context).textTheme.headlineLarge),
                  const Spacer(),
                  if (_cycleCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Text(
                        '$_cycleCount cycles',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                '4-7-8 Breathing',
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const Spacer(),

              // ── Animated Breathing Circle ──────────────────────────────
              AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  final scale = _isRunning
                      ? (0.6 + _controller.value * 0.4)
                      : 0.75;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow rings
                      ...List.generate(3, (i) {
                        final ringScale = scale + i * 0.12;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 260 * ringScale,
                          height: 260 * ringScale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: color.withOpacity(0.08 - i * 0.02),
                              width: 1,
                            ),
                          ),
                        );
                      }),
                      // Main circle
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: 220 * scale,
                        height: 220 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              color.withOpacity(0.3),
                              color.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                          border: Border.all(
                            color: color.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: Text(
                                _isRunning ? _phaseLabels[_phase]! : 'Ready',
                                key: ValueKey(_phase),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (_isRunning) ...[
                              const SizedBox(height: 8),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  '$_countdown',
                                  key: ValueKey(_countdown),
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 48,
                                    fontWeight: FontWeight.w200,
                                  ),
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

              const Spacer(),

              // ── Phase Indicators ────────────────────────────────────────
              if (_isRunning)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: BreathPhase.values.map((p) {
                    final isActive = _phase == p;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? color : AppTheme.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 32),

              // ── Control Button ──────────────────────────────────────────
              GestureDetector(
                onTap: _isRunning ? _pause : _start,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 200,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: _isRunning
                        ? const LinearGradient(
                            colors: [AppTheme.cardSurface, AppTheme.cardSurface2])
                        : AppTheme.sageGradient,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: _isRunning ? AppTheme.divider : Colors.transparent,
                    ),
                    boxShadow: _isRunning ? null : AppTheme.glowSage,
                  ),
                  child: Center(
                    child: Text(
                      _isRunning ? 'Pause' : 'Begin Practice',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Inhale 4s · Hold 7s · Exhale 8s',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
