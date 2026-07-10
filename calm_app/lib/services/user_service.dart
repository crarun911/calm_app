import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference? get _userDoc {
    if (_uid == null) return null;
    return _db.collection('users').doc(_uid);
  }

  // ── Initialize user ───────────────────────────────────────────────────────

  Future<void> initializeUser() async {
    if (_uid == null) return;
    final doc = await _userDoc!.get();
    if (!doc.exists) {
      await _userDoc!.set({
        'uid': _uid,
        'email': _auth.currentUser?.email,
        'name': _auth.currentUser?.displayName,
        'minutesMeditated': 0,
        'streakDays': 0,
        'totalSessions': 0,
        // Per-category totals
        'meditationSessions': 0,
        'meditationMinutes': 0,
        'breathingSessions': 0,
        'breathingMinutes': 0,
        'sleepSessions': 0,
        'sleepMinutes': 0,
        'lastSessionDate': null,
        'lastStreakDate': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ── Get user stats ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getUserStats() async {
    if (_uid == null) return {};
    final doc = await _userDoc!.get();
    if (!doc.exists) return {};
    return doc.data() as Map<String, dynamic>;
  }

  // ── Stream user stats ──────────────────────────────────────────────────────

  Stream<Map<String, dynamic>> userStatsStream() {
    if (_uid == null) return Stream.value({});
    return _userDoc!.snapshots().map((doc) {
      if (!doc.exists) return {};
      return doc.data() as Map<String, dynamic>;
    });
  }

  // ── Complete a session ────────────────────────────────────────────────────
  // category: 'meditation' | 'breathing' | 'sleep'

  Future<void> completeSession(int sessionMinutes,
      {String category = 'meditation'}) async {
    if (_uid == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final doc = await _userDoc!.get();
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final int currentMinutes = data['minutesMeditated'] ?? 0;
    final int currentStreak = data['streakDays'] ?? 0;
    final int totalSessions = data['totalSessions'] ?? 0;

    // ── Streak logic ──────────────────────────────────────────────────────
    int newStreak = currentStreak;
    final Timestamp? lastStreakTimestamp = data['lastStreakDate'];

    if (lastStreakTimestamp == null) {
      newStreak = 1;
    } else {
      final DateTime lastDay = DateTime(
        lastStreakTimestamp.toDate().year,
        lastStreakTimestamp.toDate().month,
        lastStreakTimestamp.toDate().day,
      );
      final int daysDiff = today.difference(lastDay).inDays;

      if (daysDiff == 0) {
        newStreak = currentStreak;
      } else if (daysDiff == 1) {
        newStreak = currentStreak + 1;
      } else {
        newStreak = 1;
      }
    }

    // ── Category-specific fields ──────────────────────────────────────────
    final String sessionsField = '${category}Sessions';
    final String minutesField = '${category}Minutes';
    final int currentCatSessions = data[sessionsField] ?? 0;
    final int currentCatMinutes = data[minutesField] ?? 0;

    // ── Update Firestore ──────────────────────────────────────────────────
    await _userDoc!.update({
      'minutesMeditated': currentMinutes + sessionMinutes,
      'streakDays': newStreak,
      'totalSessions': totalSessions + 1,
      'lastSessionDate': FieldValue.serverTimestamp(),
      'lastStreakDate': FieldValue.serverTimestamp(),
      // Category-specific
      sessionsField: currentCatSessions + 1,
      minutesField: currentCatMinutes + sessionMinutes,
    });

    // ── Save session to history ───────────────────────────────────────────
    await _db
        .collection('users')
        .doc(_uid)
        .collection('sessions')
        .add({
      'minutes': sessionMinutes,
      'category': category,
      'completedAt': FieldValue.serverTimestamp(),
      'date': today.toIso8601String(),
      'dayOfWeek': today.weekday, // 1=Mon, 7=Sun
      'month': today.month,
      'year': today.year,
    });
  }

  // ── Get sessions for a period ─────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getSessionsForPeriod(
      String period) async {
    if (_uid == null) return [];

    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 'daily':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'weekly':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'monthly':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'yearly':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('sessions')
        .where('completedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .orderBy('completedAt', descending: false)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // ── Get activity stats for period ─────────────────────────────────────────

  Future<ActivityStats> getActivityStats(String period) async {
    final sessions = await getSessionsForPeriod(period);

    int meditationSessions = 0;
    int meditationMinutes = 0;
    int breathingSessions = 0;
    int breathingMinutes = 0;
    int sleepSessions = 0;
    int sleepMinutes = 0;

    for (final s in sessions) {
      final cat = s['category'] as String? ?? 'meditation';
      final mins = s['minutes'] as int? ?? 0;

      switch (cat) {
        case 'meditation':
          meditationSessions++;
          meditationMinutes += mins;
          break;
        case 'breathing':
          breathingSessions++;
          breathingMinutes += mins;
          break;
        case 'sleep':
          sleepSessions++;
          sleepMinutes += mins;
          break;
      }
    }

    return ActivityStats(
      totalSessions: sessions.length,
      totalMinutes: meditationMinutes + breathingMinutes + sleepMinutes,
      meditationSessions: meditationSessions,
      meditationMinutes: meditationMinutes,
      breathingSessions: breathingSessions,
      breathingMinutes: breathingMinutes,
      sleepSessions: sleepSessions,
      sleepMinutes: sleepMinutes,
      sessions: sessions,
    );
  }

  // ── Get bar chart data for period ─────────────────────────────────────────

  Future<List<double>> getBarChartData(String period) async {
    final sessions = await getSessionsForPeriod(period);
    final now = DateTime.now();

    if (period == 'daily') {
      // Hours 0-23
      final data = List<double>.filled(24, 0);
      for (final s in sessions) {
        final Timestamp? ts = s['completedAt'];
        if (ts != null) {
          final hour = ts.toDate().hour;
          data[hour] += (s['minutes'] as int? ?? 0).toDouble();
        }
      }
      return data;
    } else if (period == 'weekly') {
      // Days Mon-Sun (1-7)
      final data = List<double>.filled(7, 0);
      for (final s in sessions) {
        final day = s['dayOfWeek'] as int? ?? 1;
        data[day - 1] += (s['minutes'] as int? ?? 0).toDouble();
      }
      return data;
    } else if (period == 'monthly') {
      // Weeks 1-4
      final data = List<double>.filled(4, 0);
      for (final s in sessions) {
        final Timestamp? ts = s['completedAt'];
        if (ts != null) {
          final day = ts.toDate().day;
          final week = ((day - 1) / 7).floor().clamp(0, 3);
          data[week] += (s['minutes'] as int? ?? 0).toDouble();
        }
      }
      return data;
    } else {
      // Months Jan-Dec
      final data = List<double>.filled(12, 0);
      for (final s in sessions) {
        final month = s['month'] as int? ?? 1;
        data[month - 1] += (s['minutes'] as int? ?? 0).toDouble();
      }
      return data;
    }
  }

  // ── Weekly streak ──────────────────────────────────────────────────────────

  Future<List<bool>> getWeeklyStreak() async {
    if (_uid == null) return List.filled(7, false);

    final now = DateTime.now();
    final List<bool> week = List.filled(7, false);

    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('sessions')
        .where('completedAt',
            isGreaterThan: Timestamp.fromDate(
                now.subtract(const Duration(days: 7))))
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final Timestamp? ts = data['completedAt'];
      if (ts == null) continue;
      final DateTime sessionDate = ts.toDate();
      final int daysAgo = now.difference(sessionDate).inDays;
      if (daysAgo < 7) week[6 - daysAgo] = true;
    }

    return week;
  }
}

// ── Activity Stats Model ──────────────────────────────────────────────────────

class ActivityStats {
  final int totalSessions;
  final int totalMinutes;
  final int meditationSessions;
  final int meditationMinutes;
  final int breathingSessions;
  final int breathingMinutes;
  final int sleepSessions;
  final int sleepMinutes;
  final List<Map<String, dynamic>> sessions;

  const ActivityStats({
    required this.totalSessions,
    required this.totalMinutes,
    required this.meditationSessions,
    required this.meditationMinutes,
    required this.breathingSessions,
    required this.breathingMinutes,
    required this.sleepSessions,
    required this.sleepMinutes,
    required this.sessions,
  });

  static const empty = ActivityStats(
    totalSessions: 0,
    totalMinutes: 0,
    meditationSessions: 0,
    meditationMinutes: 0,
    breathingSessions: 0,
    breathingMinutes: 0,
    sleepSessions: 0,
    sleepMinutes: 0,
    sessions: [],
  );

  double get meditationPercentage =>
      totalMinutes == 0 ? 0 : meditationMinutes / totalMinutes;
  double get breathingPercentage =>
      totalMinutes == 0 ? 0 : breathingMinutes / totalMinutes;
  double get sleepPercentage =>
      totalMinutes == 0 ? 0 : sleepMinutes / totalMinutes;
}
