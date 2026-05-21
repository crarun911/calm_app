import 'package:flutter/foundation.dart';

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

  const Session({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.durationMin,
    required this.gradient,
    this.isFavorite = false,
    required this.instructor,
  });
}

class AppState extends ChangeNotifier {
  int _currentNavIndex = 0;
  MoodType? _selectedMood;
  bool _isPlaying = false;
  int _streakDays = 7;
  int _minutesMeditated = 142;
  List<MoodEntry> _moodHistory = [];
  Session? _currentSession;

  int get currentNavIndex => _currentNavIndex;
  MoodType? get selectedMood => _selectedMood;
  bool get isPlaying => _isPlaying;
  int get streakDays => _streakDays;
  int get minutesMeditated => _minutesMeditated;
  List<MoodEntry> get moodHistory => _moodHistory;
  Session? get currentSession => _currentSession;

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

  void completeSession() {
    _isPlaying = false;
    _minutesMeditated += _currentSession?.durationMin ?? 10;
    notifyListeners();
  }
}

// ── Data ──────────────────────────────────────────────────────────────────────

const dailyCalmSession = Session(
  id: 'daily_calm',
  title: 'Daily Calm',
  subtitle: 'Morning mindfulness to start your day',
  category: 'Mindfulness',
  durationMin: 10,
  gradient: 'sage',
  instructor: 'Sofia Arora',
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
  ),
  Session(
    id: 'med_2',
    title: 'Body Scan',
    subtitle: 'Deep awareness through sensation',
    category: 'Stress',
    durationMin: 20,
    gradient: 'sage',
    instructor: 'Sofia Arora',
  ),
  Session(
    id: 'med_3',
    title: 'Loving-Kindness',
    subtitle: 'Cultivate compassion for yourself',
    category: 'Happiness',
    durationMin: 15,
    gradient: 'rose',
    instructor: 'Priya Nair',
  ),
  Session(
    id: 'med_4',
    title: 'Focus Flow',
    subtitle: 'Sharpen attention and clarity',
    category: 'Focus',
    durationMin: 10,
    gradient: 'gold',
    instructor: 'James Chen',
  ),
  Session(
    id: 'med_5',
    title: 'Stress Relief',
    subtitle: 'Dissolve tension from the day',
    category: 'Stress',
    durationMin: 18,
    gradient: 'lavender',
    instructor: 'Priya Nair',
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
  ),
  Session(
    id: 'sleep_2',
    title: 'Ocean Drift',
    subtitle: 'Float away on gentle waves',
    category: 'Sleep Story',
    durationMin: 25,
    gradient: 'sleep',
    instructor: 'James Chen',
  ),
  Session(
    id: 'sleep_3',
    title: 'Deep Sleep',
    subtitle: 'Progressive relaxation for rest',
    category: 'Meditation',
    durationMin: 20,
    gradient: 'lavender',
    instructor: 'Priya Nair',
  ),
];

const List<Map<String, dynamic>> ambientSounds = [
  {'id': 'rain', 'name': 'Rain', 'emoji': '🌧️'},
  {'id': 'ocean', 'name': 'Ocean', 'emoji': '🌊'},
  {'id': 'forest', 'name': 'Forest', 'emoji': '🌲'},
  {'id': 'fire', 'name': 'Fireplace', 'emoji': '🔥'},
  {'id': 'cafe', 'name': 'Café', 'emoji': '☕'},
  {'id': 'wind', 'name': 'Wind', 'emoji': '💨'},
];
