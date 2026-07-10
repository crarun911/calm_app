import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';

class MoodCheckInScreen extends StatefulWidget {
  final bool showRetryPrompt;
  const MoodCheckInScreen({super.key, this.showRetryPrompt = false});

  @override
  State<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends State<MoodCheckInScreen> {
  MoodType? _selected;
  bool _moodSaved = false;

  static const _moods = [
    (type: MoodType.great, emoji: '😁', label: 'Great', color: Color(0xFF4CAF82)),
    (type: MoodType.good, emoji: '🙂', label: 'Good', color: AppTheme.sage),
    (type: MoodType.okay, emoji: '😐', label: 'Okay', color: AppTheme.gold),
    (type: MoodType.sad, emoji: '😔', label: 'Low', color: AppTheme.lavender),
    (type: MoodType.stressed, emoji: '😣', label: 'Stressed', color: AppTheme.rose),
  ];

  @override
  Widget build(BuildContext context) {
    // Show retry prompt after mood is saved
    if (_moodSaved) {
      return _RetryPromptScreen(
        selectedMood: _selected,
        onTryAgain: () {
          Navigator.pop(context);
          // Navigate back to home which has the Daily Calm card
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        onGoHome: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.midnight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40, height: 40,
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
                widget.showRetryPrompt
                    ? 'Session\nComplete ✨'
                    : 'How are you\nfeeling? ✨',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(height: 1.15),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

              const SizedBox(height: 12),

              Text(
                'How are you feeling right now?',
                style: Theme.of(context).textTheme.bodyLarge,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 48),

              // Mood Grid
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
                            ? [BoxShadow(color: mood.color.withOpacity(0.2), blurRadius: 16, spreadRadius: 2)]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(mood.emoji,
                              style: TextStyle(fontSize: isSelected ? 30 : 26)),
                          const SizedBox(height: 6),
                          Text(mood.label,
                              style: TextStyle(
                                color: isSelected ? mood.color : AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              )),
                        ],
                      ),
                    ).animate(delay: Duration(milliseconds: 300 + e.key * 60))
                        .fadeIn().scale(begin: const Offset(0.8, 0.8)),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              if (_selected != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: TextField(
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Add a note... (optional)',
                      hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 20),

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
                            setState(() => _moodSaved = true);
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.sageGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: _selected != null ? AppTheme.glowSage : null,
                      ),
                      child: const Center(
                        child: Text('Save Mood',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Skip for now',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
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

// ── Retry Prompt Screen ───────────────────────────────────────────────────────

class _RetryPromptScreen extends StatelessWidget {
  final MoodType? selectedMood;
  final VoidCallback onTryAgain;
  final VoidCallback onGoHome;

  const _RetryPromptScreen({
    required this.selectedMood,
    required this.onTryAgain,
    required this.onGoHome,
  });

  String _moodMessage(MoodType? mood) {
    switch (mood) {
      case MoodType.great: return 'Amazing! You\'re glowing today 🌟';
      case MoodType.good: return 'Great work on your practice 👏';
      case MoodType.okay: return 'Every session counts, well done 🙏';
      case MoodType.sad: return 'Be gentle with yourself today 💙';
      case MoodType.stressed: return 'You showed up — that takes courage 💪';
      default: return 'Well done on completing your session 🎉';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.midnight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Celebration
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.sageGradient,
                  boxShadow: AppTheme.glowSage,
                ),
                child: const Center(
                  child: Text('✨', style: TextStyle(fontSize: 44)),
                ),
              ).animate().scale(begin: const Offset(0.5, 0.5)).fadeIn(),

              const SizedBox(height: 28),

              Text(
                _moodMessage(selectedMood),
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 12),

              const Text(
                'Would you like to do another session?',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),

              const Spacer(),

              // Try Again button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: GestureDetector(
                  onTap: onTryAgain,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.sageGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: AppTheme.glowSage,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.replay_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text('Try Another Session',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

              const SizedBox(height: 12),

              // Go Home button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: GestureDetector(
                  onTap: onGoHome,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_rounded,
                            color: AppTheme.textSecondary, size: 20),
                        SizedBox(width: 10),
                        Text('Return Home',
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
