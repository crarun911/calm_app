import 'package:flutter/foundation.dart';
import '../services/user_service.dart';

enum MoodType { great, good, okay, sad, stressed }

class MoodEntry {
  final MoodType mood;
  final DateTime timestamp;
  MoodEntry({required this.mood, required this.timestamp});
}

class Session {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final int durationMin;
  final String gradient;
  final bool isFavorite;
  final String instructor;
  final String audioPath;

  const Session({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.durationMin,
    required this.gradient,
    this.isFavorite = false,
    required this.instructor,
    required this.audioPath,
  });
}

class AppState extends ChangeNotifier {
  final _userService = UserService();

  int _currentNavIndex = 0;
  MoodType? _selectedMood;
  bool _isPlaying = false;
  int _streakDays = 0;
  int _minutesMeditated = 0;
  int _totalSessions = 0;
  List<MoodEntry> _moodHistory = [];
  Session? _currentSession;
  List<bool> _weeklyStreak = List.filled(7, false);
  bool _isLoading = false;

  int get currentNavIndex => _currentNavIndex;
  MoodType? get selectedMood => _selectedMood;
  bool get isPlaying => _isPlaying;
  int get streakDays => _streakDays;
  int get minutesMeditated => _minutesMeditated;
  int get totalSessions => _totalSessions;
  List<MoodEntry> get moodHistory => _moodHistory;
  Session? get currentSession => _currentSession;
  List<bool> get weeklyStreak => _weeklyStreak;
  bool get isLoading => _isLoading;

  // ── Load stats from Firestore ─────────────────────────────────────────────

  Future<void> loadUserStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.initializeUser();
      final stats = await _userService.getUserStats();

      _streakDays = stats['streakDays'] ?? 0;
      _minutesMeditated = stats['minutesMeditated'] ?? 0;
      _totalSessions = stats['totalSessions'] ?? 0;
      _weeklyStreak = await _userService.getWeeklyStreak();
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Listen to real-time updates ───────────────────────────────────────────

  void listenToUserStats() {
    _userService.userStatsStream().listen((stats) {
      if (stats.isEmpty) return;
      _streakDays = stats['streakDays'] ?? 0;
      _minutesMeditated = stats['minutesMeditated'] ?? 0;
      _totalSessions = stats['totalSessions'] ?? 0;
      notifyListeners();
    });
  }

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  void setMood(MoodType mood) {
    _selectedMood = mood;
    _moodHistory.insert(0, MoodEntry(mood: mood, timestamp: DateTime.now()));
    notifyListeners();
  }

  void togglePlayback() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void setCurrentSession(Session session) {
    _currentSession = session;
    _isPlaying = true;
    notifyListeners();
  }

  // ── Complete session — saves to Firestore ─────────────────────────────────

  Future<void> completeSession({String category = 'meditation'}) async {
    _isPlaying = false;
    final minutes = _currentSession?.durationMin ?? 10;

    // Save to Firestore with category
    await _userService.completeSession(minutes, category: category);

    // Refresh weekly streak dots
    _weeklyStreak = await _userService.getWeeklyStreak();

    notifyListeners();
  }
}

// ── Session Data ──────────────────────────────────────────────────────────────

const dailyCalmSession = Session(
  id: 'daily_calm',
  title: 'Daily Calm',
  subtitle: 'Morning mindfulness to start your day',
  category: 'Mindfulness',
  durationMin: 10,
  gradient: 'sage',
  instructor: 'Sofia Arora',
  audioPath: 'assets/audio/daily_calm.mp3',
);

const List<Session> meditationSessions = [
  Session(
    id: 'med_1',
    title: 'Releasing Anxiety',
    subtitle: 'Let go of what holds you back',
    category: 'Anxiety',
    durationMin: 12,
    gradient: 'lavender',
    instructor: 'James Chen',
    audioPath: 'assets/audio/releasing_anxiety.mp3',
  ),
  Session(
    id: 'med_2',
    title: 'Body Scan',
    subtitle: 'Deep awareness through sensation',
    category: 'Stress',
    durationMin: 20,
    gradient: 'sage',
    instructor: 'Sofia Arora',
    audioPath: 'assets/audio/body_scan.mp3',
  ),
  Session(
    id: 'med_3',
    title: 'Loving-Kindness',
    subtitle: 'Cultivate compassion for yourself',
    category: 'Happiness',
    durationMin: 15,
    gradient: 'rose',
    instructor: 'Priya Nair',
    audioPath: 'assets/audio/loving_kindness.mp3',
  ),
  Session(
    id: 'med_4',
    title: 'Focus Flow',
    subtitle: 'Sharpen attention and clarity',
    category: 'Focus',
    durationMin: 10,
    gradient: 'gold',
    instructor: 'James Chen',
    audioPath: 'assets/audio/focus_flow.mp3',
  ),
  Session(
    id: 'med_5',
    title: 'Stress Relief',
    subtitle: 'Dissolve tension from the day',
    category: 'Stress',
    durationMin: 18,
    gradient: 'lavender',
    instructor: 'Priya Nair',
    audioPath: 'assets/audio/stress_relief.mp3',
  ),
];

const List<Session> sleepSessions = [
  Session(
    id: 'sleep_1',
    title: 'Forest at Midnight',
    subtitle: 'A journey through ancient trees',
    category: 'Sleep Story',
    durationMin: 30,
    gradient: 'sleep',
    instructor: 'Sofia Arora',
    audioPath: 'assets/audio/forest_midnight.mp3',
  ),
  Session(
    id: 'sleep_2',
    title: 'Ocean Drift',
    subtitle: 'Float away on gentle waves',
    category: 'Sleep Story',
    durationMin: 25,
    gradient: 'sleep',
    instructor: 'James Chen',
    audioPath: 'assets/audio/ocean_drift.mp3',
  ),
  Session(
    id: 'sleep_3',
    title: 'Deep Sleep',
    subtitle: 'Progressive relaxation for rest',
    category: 'Meditation',
    durationMin: 20,
    gradient: 'lavender',
    instructor: 'Priya Nair',
    audioPath: 'assets/audio/deep_sleep.mp3',
  ),
];

const List<Map<String, dynamic>> ambientSounds = [
  {'id': 'rain', 'name': 'Rain', 'emoji': '🌧️', 'audioPath': 'assets/audio/ambient_rain.mp3'},
  {'id': 'ocean', 'name': 'Ocean', 'emoji': '🌊', 'audioPath': 'assets/audio/ambient_ocean.mp3'},
  {'id': 'forest', 'name': 'Forest', 'emoji': '🌲', 'audioPath': 'assets/audio/ambient_forest.mp3'},
  {'id': 'fire', 'name': 'Fireplace', 'emoji': '🔥', 'audioPath': 'assets/audio/ambient_fire.mp3'},
  {'id': 'cafe', 'name': 'Café', 'emoji': '☕', 'audioPath': 'assets/audio/ambient_cafe.mp3'},
  {'id': 'wind', 'name': 'Wind', 'emoji': '💨', 'audioPath': 'assets/audio/ambient_wind.mp3'},
];
