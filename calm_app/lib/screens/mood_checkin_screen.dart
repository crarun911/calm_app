import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';

class MoodCheckInScreen extends StatefulWidget {
  const MoodCheckInScreen({super.key});

  @override
  State<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends State<MoodCheckInScreen> {
  MoodType? _selected;

  static const _moods = [
    (type: MoodType.great, emoji: '😁', label: 'Great', color: Color(0xFF4CAF82)),
    (type: MoodType.good, emoji: '🙂', label: 'Good', color: AppTheme.sage),
    (type: MoodType.okay, emoji: '😐', label: 'Okay', color: AppTheme.gold),
    (type: MoodType.sad, emoji: '😔', label: 'Low', color: AppTheme.lavender),
    (type: MoodType.stressed, emoji: '😣', label: 'Stressed', color: AppTheme.rose),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.midnight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
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

              const SizedBox(height: 40),

              Text(
                'How are you\nfeeling? ✨',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      height: 1.15,
                    ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

              const SizedBox(height: 12),

              Text(
                'Select your current mood',
                style: Theme.of(context).textTheme.bodyLarge,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 48),

              // ── Mood Grid ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _moods.asMap().entries.map((e) {
                  final mood = e.value;
                  final isSelected = _selected == mood.type;

                  return GestureDetector(
                    onTap: () => setState(() => _selected = mood.type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutBack,
                      width: isSelected ? 66 : 58,
                      height: isSelected ? 88 : 80,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? mood.color.withOpacity(0.15)
                            : AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? mood.color.withOpacity(0.6)
                              : AppTheme.divider,
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: mood.color.withOpacity(0.2),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            mood.emoji,
                            style: TextStyle(
                              fontSize: isSelected ? 30 : 26,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            mood.label,
                            style: TextStyle(
                              color: isSelected
                                  ? mood.color
                                  : AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ).animate(
                            delay: Duration(
                                milliseconds: 300 + e.key * 60))
                        .fadeIn()
                        .scale(begin: const Offset(0.8, 0.8)),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // ── Note field ───────────────────────────────────────────────
              if (_selected != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: TextField(
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 14),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText:
                          'Add a note about how you\'re feeling... (optional)',
                      hintStyle: TextStyle(
                          color: AppTheme.textMuted, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 20),

              // ── Save Button — navigates to HOME ──────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _selected != null ? 1.0 : 0.4,
                  child: GestureDetector(
                    onTap: _selected == null
                        ? null
                        : () {
                            context.read<AppState>().setMood(_selected!);
                            // Pop all routes back to home (index 0)
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.sageGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow:
                            _selected != null ? AppTheme.glowSage : null,
                      ),
                      child: const Center(
                        child: Text(
                          'Save & Go Home',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Skip — also goes home ────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context)
                      .popUntil((route) => route.isFirst),
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
