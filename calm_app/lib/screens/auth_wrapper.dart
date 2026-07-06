import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/auth_service.dart';
import 'main_shell.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Still loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D1117),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7CB9A0),
                strokeWidth: 2,
              ),
            ),
          );
        }

        // Logged in → load stats then show app
        if (snapshot.hasData && snapshot.data != null) {
          // Load user stats from Firestore when user logs in
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final appState = context.read<AppState>();
            appState.loadUserStats();
            appState.listenToUserStats();
          });
          return const MainShell();
        }

        // Not logged in → show login
        return const LoginScreen();
      },
    );
  }
}
