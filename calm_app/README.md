# 🧘 Calm App — Flutter

A beautiful mindfulness and meditation app for iOS & Android, built with Flutter.

## ✨ Screens Implemented

| Screen | Route | Description |
|---|---|---|
| 🏠 Home | `/` (tab 0) | Daily Calm card, quick actions, stats, recommended sessions |
| 🎧 Audio Player | Push route | Full-screen player with animated artwork, progress, sleep timer |
| 📊 Mood Check-in | Push route | 5-emoji mood selector with optional note |
| 🌙 Recommendation | Push route | Mood-aware content suggestions (Sleep / Meditate / Energy) |
| 🌙 Sleep | `/sleep` (tab 2) | Sleep stories + ambient sound tiles |
| 🧘 Meditate | `/meditate` (tab 1) | Category filter chips + session list |
| 🌬️ Breathe | `/breathe` | Animated 4-7-8 breathing circle with phase timer |
| 👤 Profile | (tab 4) | Stats, mood history, premium banner, settings |
| 😊 Mood | (tab 3) | Mood check-in accessible from nav |

## 🎨 Design System

- **Palette**: Midnight navy (`#0D1117`) with sage green (`#7CB9A0`), warm gold (`#D4A853`), and lavender accent
- **Typography**: Cormorant Garamond (headings) + DM Sans (body)
- **Animations**: `flutter_animate` for staggered entrance animations throughout
- **Audio player**: Rotating disc artwork with pulsing ring animations

## 🔗 Navigation Flows (as specified)

```
Home → [Tap Daily Calm] → Audio Player → [Done/Complete] → Mood Check-in → Recommendation
Recommendation → Sleep Screen OR Meditate Screen → Audio Player (loop)
Quick Actions: Breathe / Sleep / Meditate / Mood
Bottom Nav: Home | Meditate | Sleep | Mood | Profile
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio / Xcode
- A connected device or emulator

### Installation

```bash
# Clone / copy the project
cd calm_app

# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build for Android
flutter build apk --release

# Build for iOS (requires macOS + Xcode)
flutter build ios --release
```

### iOS Setup

```bash
cd ios
pod install
cd ..
flutter run -d iPhone
```

Add to `ios/Runner/Info.plist` if using audio:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Used for ambient sound recording</string>
```

### Android Setup

Min SDK is set to 21 (Android 5.0+). No additional setup needed.

## 📦 Dependencies

```yaml
google_fonts: ^6.1.0        # Cormorant Garamond + DM Sans
provider: ^6.1.1            # State management
audioplayers: ^5.2.1        # Audio playback
flutter_animate: ^4.3.0     # Entrance animations
fl_chart: ^0.66.2           # Mood history charts
percent_indicator: ^4.2.3   # Progress rings
lottie: ^3.0.0              # Lottie animations (ready to use)
```

## 🗂️ Project Structure

```
lib/
├── main.dart                  # App entry point, routes
├── theme/
│   └── app_theme.dart         # Colors, gradients, typography
├── models/
│   └── app_state.dart         # ChangeNotifier state + session data
├── widgets/
│   └── common_widgets.dart    # GradientSessionCard, StatChip, CategoryPill
└── screens/
    ├── main_shell.dart        # Bottom nav scaffold
    ├── home_screen.dart       # 🏠 Home
    ├── audio_player_screen.dart # 🎧 Player
    ├── mood_checkin_screen.dart # 📊 Mood
    ├── recommendation_screen.dart # 🌙 Recommendations
    ├── sleep_screen.dart      # 🌙 Sleep
    ├── meditate_screen.dart   # 🧘 Meditate
    ├── breathing_screen.dart  # 🌬️ Breathe
    └── profile_screen.dart    # 👤 Profile
```

## 🔧 Extending the App

### Adding Real Audio

In `audio_player_screen.dart`, the `audioplayers` package is already a dependency. Replace the timer simulation:

```dart
import 'package:audioplayers/audioplayers.dart';

final _player = AudioPlayer();

// In _togglePlay():
await _player.play(AssetSource('audio/daily_calm.mp3'));
// or
await _player.play(UrlSource('https://your-cdn.com/session.mp3'));
```

### Adding Lottie Animations

```dart
import 'package:lottie/lottie.dart';

Lottie.asset('assets/animations/breathing.json',
  controller: _controller,
  width: 200,
)
```

### Backend / Auth

Swap `AppState` for a proper service layer (Riverpod / Bloc recommended for production scale).

## 📱 Platform Notes

| Feature | Android | iOS |
|---|---|---|
| Haptic feedback | ✅ | ✅ |
| Status bar styling | ✅ | ✅ |
| Bottom safe area | ✅ | ✅ |
| Background audio | Needs service | Needs AVAudioSession |
| Notifications | Add `flutter_local_notifications` | Add `flutter_local_notifications` |
