import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final List<ReminderItem> _reminders = [
    ReminderItem(
      id: '1',
      label: 'Morning Meditation',
      time: TimeOfDay(hour: 7, minute: 0),
      emoji: '🌅',
      days: {1, 2, 3, 4, 5},
      enabled: true,
    ),
    ReminderItem(
      id: '2',
      label: 'Evening Wind Down',
      time: TimeOfDay(hour: 21, minute: 30),
      emoji: '🌙',
      days: {1, 2, 3, 4, 5, 6, 7},
      enabled: false,
    ),
  ];

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminders[index].time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.sage,
              surface: AppTheme.cardSurface,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _reminders[index] = _reminders[index].copyWith(time: picked));
    }
  }

  void _toggleDay(int reminderIndex, int day) {
    final reminder = _reminders[reminderIndex];
    final days = Set<int>.from(reminder.days);
    if (days.contains(day)) {
      days.remove(day);
    } else {
      days.add(day);
    }
    setState(() =>
        _reminders[reminderIndex] = reminder.copyWith(days: days));
  }

  void _addReminder() {
    setState(() {
      _reminders.add(ReminderItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: 'Meditation Reminder',
        time: const TimeOfDay(hour: 9, minute: 0),
        emoji: '🧘',
        days: {1, 2, 3, 4, 5},
        enabled: true,
      ));
    });
  }

  void _deleteReminder(int index) {
    setState(() => _reminders.removeAt(index));
  }

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Reminders',
                                style: Theme.of(context).textTheme.headlineLarge),
                            const Text('Schedule your practice',
                                style: TextStyle(
                                    color: AppTheme.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _addReminder,
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          gradient: AppTheme.sageGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Info banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.sage.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.sage.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.notifications_outlined,
                        color: AppTheme.sage, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Reminders help you build a consistent daily practice',
                        style: TextStyle(
                            color: AppTheme.sageLight,
                            fontSize: 12,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: _ReminderCard(
                  reminder: _reminders[i],
                  dayLabels: _dayLabels,
                  onToggleEnabled: (v) => setState(
                      () => _reminders[i] = _reminders[i].copyWith(enabled: v)),
                  onPickTime: () => _pickTime(i),
                  onToggleDay: (day) => _toggleDay(i, day),
                  onDelete: () => _deleteReminder(i),
                  onEditLabel: (label) => setState(
                      () => _reminders[i] = _reminders[i].copyWith(label: label)),
                ).animate(delay: Duration(milliseconds: 150 + i * 80))
                    .fadeIn().slideY(begin: 0.05),
              ),
              childCount: _reminders.length,
            ),
          ),

          // Suggested reminders
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Suggested',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  ...[
                    ('🌅', 'Wake Up Meditation', '7:00 AM'),
                    ('☀️', 'Midday Reset', '12:00 PM'),
                    ('🌆', 'After Work', '6:00 PM'),
                    ('🌙', 'Sleep Prep', '9:30 PM'),
                  ].map((s) => GestureDetector(
                        onTap: () {
                          final parts = s.$3.split(':');
                          final hour = int.parse(parts[0]);
                          final min = int.parse(parts[1].split(' ')[0]);
                          final isPm = s.$3.contains('PM');
                          setState(() {
                            _reminders.add(ReminderItem(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              label: s.$2,
                              time: TimeOfDay(
                                  hour: isPm && hour != 12 ? hour + 12 : hour,
                                  minute: min),
                              emoji: s.$1,
                              days: {1, 2, 3, 4, 5},
                              enabled: true,
                            ));
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: Row(
                            children: [
                              Text(s.$1,
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(s.$2,
                                    style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 14)),
                              ),
                              Text(s.$3,
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13)),
                              const SizedBox(width: 8),
                              const Icon(Icons.add_circle_outline_rounded,
                                  color: AppTheme.sage, size: 20),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final ReminderItem reminder;
  final List<String> dayLabels;
  final ValueChanged<bool> onToggleEnabled;
  final VoidCallback onPickTime;
  final ValueChanged<int> onToggleDay;
  final VoidCallback onDelete;
  final ValueChanged<String> onEditLabel;

  const _ReminderCard({
    required this.reminder,
    required this.dayLabels,
    required this.onToggleEnabled,
    required this.onPickTime,
    required this.onToggleDay,
    required this.onDelete,
    required this.onEditLabel,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = reminder.time.format(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: reminder.enabled
              ? AppTheme.sage.withOpacity(0.3)
              : AppTheme.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(reminder.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final ctrl =
                        TextEditingController(text: reminder.label);
                    final result = await showDialog<String>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: AppTheme.cardSurface,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: const Text('Edit Label',
                            style:
                                TextStyle(color: AppTheme.textPrimary)),
                        content: TextField(
                          controller: ctrl,
                          style: const TextStyle(
                              color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppTheme.divider),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppTheme.sage),
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, ctrl.text),
                            child: const Text('Save',
                                style:
                                    TextStyle(color: AppTheme.sage)),
                          ),
                        ],
                      ),
                    );
                    if (result != null && result.isNotEmpty) {
                      onEditLabel(result);
                    }
                  },
                  child: Text(reminder.label,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ),
              ),
              Switch(
                value: reminder.enabled,
                onChanged: onToggleEnabled,
                activeColor: AppTheme.sage,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Time picker
          GestureDetector(
            onTap: onPickTime,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.midnight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time_rounded,
                      color: AppTheme.sage, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    timeStr,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit_rounded,
                      color: AppTheme.textMuted, size: 14),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Day selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final day = i + 1;
              final isSelected = reminder.days.contains(day);
              return GestureDetector(
                onTap: () => onToggleDay(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppTheme.sage
                        : AppTheme.midnight,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.sage
                          : AppTheme.divider,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      dayLabels[i],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Delete
          GestureDetector(
            onTap: onDelete,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.delete_outline_rounded,
                    color: AppTheme.rose, size: 16),
                SizedBox(width: 4),
                Text('Delete',
                    style:
                        TextStyle(color: AppTheme.rose, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReminderItem {
  final String id;
  final String label;
  final TimeOfDay time;
  final String emoji;
  final Set<int> days;
  final bool enabled;

  const ReminderItem({
    required this.id,
    required this.label,
    required this.time,
    required this.emoji,
    required this.days,
    required this.enabled,
  });

  ReminderItem copyWith({
    String? label,
    TimeOfDay? time,
    String? emoji,
    Set<int>? days,
    bool? enabled,
  }) =>
      ReminderItem(
        id: id,
        label: label ?? this.label,
        time: time ?? this.time,
        emoji: emoji ?? this.emoji,
        days: days ?? this.days,
        enabled: enabled ?? this.enabled,
      );
}
