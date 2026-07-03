import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'models/app_state.dart';
import 'screens/auth_wrapper.dart';
import 'screens/breathing_screen.dart';
import 'screens/sleep_screen.dart';
import 'screens/meditate_screen.dart';
import 'screens/mood_checkin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

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
        theme: AppTheme.darkTheme.copyWith(
                  pageTransitionsTheme: const PageTransitionsTheme(
                    builders: {
                      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                    },
                  ),
                ),
        // AuthWrapper handles login vs home automatically
        home: const AuthWrapper(),
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
