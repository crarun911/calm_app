import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current user ID
  String? get _uid => _auth.currentUser?.uid;

  // Reference to user document
  DocumentReference? get _userDoc {
    if (_uid == null) return null;
    return _db.collection('users').doc(_uid);
  }

  // ── Initialize user on first login ────────────────────────────────────────

  Future<void> initializeUser() async {
    if (_uid == null) return;

    final doc = await _userDoc!.get();

    // Only create if doesn't exist
    if (!doc.exists) {
      await _userDoc!.set({
        'uid': _uid,
        'email': _auth.currentUser?.email,
        'name': _auth.currentUser?.displayName,
        'minutesMeditated': 0,
        'streakDays': 0,
        'totalSessions': 0,
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

  // ── Stream user stats in real time ────────────────────────────────────────

  Stream<Map<String, dynamic>> userStatsStream() {
    if (_uid == null) return Stream.value({});

    return _userDoc!.snapshots().map((doc) {
      if (!doc.exists) return {};
      return doc.data() as Map<String, dynamic>;
    });
  }

  // ── Complete a session ────────────────────────────────────────────────────
  // Called when user taps Done in audio player

  Future<void> completeSession(int sessionMinutes) async {
    if (_uid == null) return;
    print('💾 Saving session: $sessionMinutes minutes for user $_uid');

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final doc = await _userDoc!.get();
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final int currentMinutes = data['minutesMeditated'] ?? 0;
    final int currentStreak = data['streakDays'] ?? 0;
    final int totalSessions = data['totalSessions'] ?? 0;

    // ── Calculate streak ─────────────────────────────────────────────────────
    int newStreak = currentStreak;

    final Timestamp? lastStreakTimestamp = data['lastStreakDate'];
    
    if (lastStreakTimestamp == null) {
      // First ever session
      newStreak = 1;
    } else {
      final DateTime lastStreakDate = lastStreakTimestamp.toDate();
      final DateTime lastDay = DateTime(
        lastStreakDate.year,
        lastStreakDate.month,
        lastStreakDate.day,
      );

      final int daysDiff = today.difference(lastDay).inDays;

      if (daysDiff == 0) {
        // Already meditated today — keep streak, don't increment
        newStreak = currentStreak;
      } else if (daysDiff == 1) {
        // Meditated yesterday — extend streak
        newStreak = currentStreak + 1;
      } else {
        // Missed a day — reset streak to 1
        newStreak = 1;
      }
    }

    // ── Update Firestore ─────────────────────────────────────────────────────
    await _userDoc!.update({
      'minutesMeditated': currentMinutes + sessionMinutes,
      'streakDays': newStreak,
      'totalSessions': totalSessions + 1,
      'lastSessionDate': FieldValue.serverTimestamp(),
      'lastStreakDate': FieldValue.serverTimestamp(),
    });

    // ── Save session history ─────────────────────────────────────────────────
    await _db
        .collection('users')
        .doc(_uid)
        .collection('sessions')
        .add({
      'minutes': sessionMinutes,
      'completedAt': FieldValue.serverTimestamp(),
      'date': today.toIso8601String(),
    });
  }

  // ── Get session history ───────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getSessionHistory() async {
    if (_uid == null) return [];

    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('sessions')
        .orderBy('completedAt', descending: true)
        .limit(30)
        .get();

    return snapshot.docs
        .map((doc) => doc.data())
        .toList();
  }

  // ── Get streak calendar (last 7 days) ─────────────────────────────────────

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

      if (daysAgo < 7) {
        week[6 - daysAgo] = true;
      }
    }

    return week;
  }
}
