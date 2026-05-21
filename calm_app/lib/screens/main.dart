import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'models/app_state.dart';
import 'screens/main_shell.dart';
import 'screens/breathing_screen.dart';
import 'screens/sleep_screen.dart';
import 'screens/meditate_screen.dart';
import 'screens/mood_checkin_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable slow-motion animations on low-end devices
  timeDilation = 1.0;

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: Colors.transparent,
  ));
  runApp(const CalmApp());
}

class CalmApp extends StatelessWidget {
  const CalmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Calm',
        debugShowCheckedModeBanner: false,
        // Disable transition animations to reduce CPU load
        theme: AppTheme.darkTheme.copyWith(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        home: const MainShell(),
        routes: {
          '/breathe': (_) => const BreathingScreen(),
          '/sleep': (_) => const SleepScreen(),
          '/meditate': (_) => const MeditateScreen(),
          '/mood': (_) => const MoodCheckInScreen(),
        },
      ),
    );
  }
}
