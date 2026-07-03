import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/main_shell.dart';
import '../screens/login_screen.dart';

// This widget listens to auth state and shows
// either the app or login screen automatically
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

        // Logged in → show app
        if (snapshot.hasData && snapshot.data != null) {
          return const MainShell();
        }

        // Not logged in → show login
        return const LoginScreen();
      },
    );
  }
}
