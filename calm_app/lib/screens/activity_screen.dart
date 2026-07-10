import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../services/user_service.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

enum ActivityPeriod { daily, weekly, monthly, yearly }

class _ActivityScreenState extends State<ActivityScreen> {
  ActivityPeriod _period = ActivityPeriod.weekly;
  ActivityStats _stats = ActivityStats.empty;
  List<double> _chartData = [];
  bool _isLoading = true;
  final _userService = UserService();

  static const _periodKeys = {
    ActivityPeriod.daily: 'daily',
    ActivityPeriod.weekly: 'weekly',
    ActivityPeriod.monthly: 'monthly',
    ActivityPeriod.yearly: 'yearly',
  };

  static const _periodLabels = {
    ActivityPeriod.daily: 'Today',
    ActivityPeriod.weekly: 'This Week',
    ActivityPeriod.monthly: 'This Month',
    ActivityPeriod.yearly: 'This Year',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final key = _periodKeys[_period]!;
    final stats = await _userService.getActivityStats(key);
    final chart = await _userService.getBarChartData(key);
    if (mounted) {
      setState(() {
        _stats = stats;
        _chartData = chart;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.midnight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                        const SizedBox(width: 16),
                        Text('Activity',
                            style:
                                Theme.of(context).textTheme.headlineLarge),
                      ],
                    ),
                    // Refresh button
                    GestureDetector(
                      onTap: _loadData,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: const Icon(Icons.refresh_rounded,
                            color: AppTheme.textSecondary, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Period Selector ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: ActivityPeriod.values.map((p) {
                    final isSelected = _period == p;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _period = p);
                          _loadData();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            gradient:
                                isSelected ? AppTheme.sageGradient : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _periodLabels[p]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ).animate().fadeIn(delay: 100.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(60),
                  child: CircularProgressIndicator(
                    color: AppTheme.sage,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else ...[
            // ── Summary Stats ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _periodLabels[_period]!,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _BigStatCard(
                            value: '${state.streakDays}',
                            label: 'Day Streak',
                            icon: '🔥',
                            color: AppTheme.gold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _BigStatCard(
                            value: _formatTime(_stats.totalMinutes),
                            label: 'Total Time',
                            icon: '⏱️',
                            color: AppTheme.sage,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _BigStatCard(
                            value: '${_stats.totalSessions}',
                            label: 'Sessions',
                            icon: '✅',
                            color: AppTheme.lavender,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _BigStatCard(
                            value: '${_stats.totalMinutes}',
                            label: 'Minutes',
                            icon: '🧘',
                            color: AppTheme.rose,
                          ),
                        ),
                      ],
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Bar Chart ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _ActivityBarChart(
                  period: _period,
                  data: _chartData,
                ).animate().fadeIn(delay: 300.ms),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Activity Breakdown ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Activity Breakdown',
                        style:
                            Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 14),
                    _ActivityRow(
                      emoji: '🧘',
                      label: 'Meditation',
                      sessions: _stats.meditationSessions,
                      minutes: _stats.meditationMinutes,
                      color: AppTheme.sage,
                      percentage: _stats.meditationPercentage,
                    ),
                    const SizedBox(height: 10),
                    _ActivityRow(
                      emoji: '🌬️',
                      label: 'Breathing',
                      sessions: _stats.breathingSessions,
                      minutes: _stats.breathingMinutes,
                      color: AppTheme.lavender,
                      percentage: _stats.breathingPercentage,
                    ),
                    const SizedBox(height: 10),
                    _ActivityRow(
                      emoji: '🌙',
                      label: 'Sleep',
                      sessions: _stats.sleepSessions,
                      minutes: _stats.sleepMinutes,
                      color: const Color(0xFF5BA4CF),
                      percentage: _stats.sleepPercentage,
                    ),

                    // Empty state
                    if (_stats.totalSessions == 0) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Column(
                          children: [
                            const Text('🌱',
                                style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 12),
                            Text(
                              'No sessions ${_periodLabels[_period]!.toLowerCase()} yet',
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Complete a session to start tracking your activity',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ).animate().fadeIn(delay: 400.ms),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Mood Graph ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _MoodGraph(state: state)
                    .animate().fadeIn(delay: 500.ms),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Weekly Calendar ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _WeeklyCalendar(streak: state.weeklyStreak)
                    .animate().fadeIn(delay: 600.ms),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  String _formatTime(int minutes) {
    if (minutes == 0) return '0m';
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}

// ── Big Stat Card ─────────────────────────────────────────────────────────────

class _BigStatCard extends StatelessWidget {
  final String value;
  final String label;
  final String icon;
  final Color color;

  const _BigStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.1)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Activity Bar Chart ────────────────────────────────────────────────────────

class _ActivityBarChart extends StatelessWidget {
  final ActivityPeriod period;
  final List<double> data;

  const _ActivityBarChart({required this.period, required this.data});

  @override
  Widget build(BuildContext context) {
    final labels = period == ActivityPeriod.daily
        ? ['6a', '9a', '12p', '3p', '6p', '9p']
        : period == ActivityPeriod.weekly
            ? ['M', 'T', 'W', 'T', 'F', 'S', 'S']
            : period == ActivityPeriod.monthly
                ? ['W1', 'W2', 'W3', 'W4']
                : ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

    // Pick subset of data to match labels
    List<double> displayData;
    if (period == ActivityPeriod.daily) {
      // Show 6am, 9am, 12pm, 3pm, 6pm, 9pm
      displayData = data.length >= 24
          ? [data[6], data[9], data[12], data[15], data[18], data[21]]
          : List.filled(6, 0);
    } else {
      displayData = data.length >= labels.length
          ? data.sublist(0, labels.length)
          : [...data, ...List.filled(labels.length - data.length, 0.0)];
    }

    final maxVal =
        displayData.isEmpty ? 1.0 : displayData.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Minutes per Period',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(displayData.length, (i) {
                final val = displayData[i];
                final height = maxVal == 0 ? 0.0 : (val / maxVal) * 80;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (val > 0)
                      Text('${val.round()}',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 8)),
                    const SizedBox(height: 2),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 400 + i * 50),
                      width: labels.length > 8 ? 18 : 26,
                      height: height.clamp(2.0, 80.0),
                      decoration: BoxDecoration(
                        gradient: val > 0
                            ? const LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [AppTheme.sage, Color(0xFF4A9B82)],
                              )
                            : null,
                        color: val == 0 ? AppTheme.divider : null,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(labels[i],
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 9)),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Activity Row ──────────────────────────────────────────────────────────────

class _ActivityRow extends StatelessWidget {
  final String emoji;
  final String label;
  final int sessions;
  final int minutes;
  final Color color;
  final double percentage;

  const _ActivityRow({
    required this.emoji,
    required this.label,
    required this.sessions,
    required this.minutes,
    required this.color,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$sessions sessions',
                      style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  Text('$minutes min',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              backgroundColor: AppTheme.divider,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mood Graph ────────────────────────────────────────────────────────────────

class _MoodGraph extends StatelessWidget {
  final AppState state;
  const _MoodGraph({required this.state});

  Color _moodColor(MoodType? mood) {
    switch (mood) {
      case MoodType.great: return const Color(0xFF4CAF82);
      case MoodType.good: return AppTheme.sage;
      case MoodType.okay: return AppTheme.gold;
      case MoodType.sad: return AppTheme.lavender;
      case MoodType.stressed: return AppTheme.rose;
      default: return AppTheme.textMuted;
    }
  }

  double _moodValue(MoodType? mood) {
    switch (mood) {
      case MoodType.great: return 1.0;
      case MoodType.good: return 0.8;
      case MoodType.okay: return 0.6;
      case MoodType.sad: return 0.3;
      case MoodType.stressed: return 0.15;
      default: return 0.5;
    }
  }

  String _moodEmoji(MoodType? mood) {
    switch (mood) {
      case MoodType.great: return '😁';
      case MoodType.good: return '🙂';
      case MoodType.okay: return '😐';
      case MoodType.sad: return '😔';
      case MoodType.stressed: return '😣';
      default: return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final history =
        state.moodHistory.take(7).toList().reversed.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mood History',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          if (history.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Complete sessions to track your mood',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Column(
              children: [
                SizedBox(
                  height: 80,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: history.map((entry) {
                      final value = _moodValue(entry.mood);
                      final color = _moodColor(entry.mood);
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(_moodEmoji(entry.mood),
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            width: 28,
                            height: 50 * value,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: history.map((entry) {
                    return Text(
                      '${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 9),
                    );
                  }).toList(),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              MoodType.great,
              MoodType.good,
              MoodType.okay,
              MoodType.sad,
              MoodType.stressed,
            ]
                .map((m) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _moodColor(m)),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          m.name[0].toUpperCase() + m.name.substring(1),
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 10),
                        ),
                      ],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Weekly Calendar ───────────────────────────────────────────────────────────

class _WeeklyCalendar extends StatelessWidget {
  final List<bool> streak;
  const _WeeklyCalendar({required this.streak});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('This Week',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final isActive = i < streak.length && streak[i];
              final isToday = i == 6;
              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isActive ? AppTheme.sageGradient : null,
                      color: isActive ? null : AppTheme.midnight,
                      border: Border.all(
                        color: isToday && !isActive
                            ? AppTheme.sage.withOpacity(0.5)
                            : isActive
                                ? Colors.transparent
                                : AppTheme.divider,
                        width: isToday ? 1.5 : 1,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                  color: AppTheme.sage.withOpacity(0.3),
                                  blurRadius: 8)
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isActive
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 16)
                          : isToday
                              ? Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        AppTheme.sage.withOpacity(0.6),
                                  ),
                                )
                              : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _days[i],
                    style: TextStyle(
                      color: isActive
                          ? AppTheme.sage
                          : isToday
                              ? AppTheme.textPrimary
                              : AppTheme.textMuted,
                      fontSize: 10,
                      fontWeight: isToday
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
