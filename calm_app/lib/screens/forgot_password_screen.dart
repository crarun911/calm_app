import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  Future<void> _sendReset() async {
    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.resetPassword(_emailController.text);
      if (mounted) setState(() => _emailSent = true);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.midnight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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

              const SizedBox(height: 40),

              if (!_emailSent) ...[
                Text('Reset password',
                    style: Theme.of(context).textTheme.displayMedium)
                    .animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 8),
                const Text(
                  "Enter your email and we'll send you a reset link",
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: 40),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'you@example.com',
                    hintStyle: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 15),
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: AppTheme.textSecondary, size: 20),
                    filled: true,
                    fillColor: AppTheme.cardSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppTheme.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: AppTheme.sage, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 16),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.rose.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.rose.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: AppTheme.rose, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_errorMessage!,
                              style: const TextStyle(
                                  color: AppTheme.rose, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: GestureDetector(
                    onTap: _isLoading ? null : _sendReset,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.sageGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppTheme.glowSage,
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 24, height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Send Reset Link',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms),

              ] else ...[
                // ── Success State ───────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.sage.withOpacity(0.15),
                          border: Border.all(
                              color: AppTheme.sage.withOpacity(0.4)),
                        ),
                        child: const Icon(Icons.mark_email_read_outlined,
                            color: AppTheme.sage, size: 36),
                      ).animate().scale(begin: const Offset(0.5, 0.5)).fadeIn(),
                      const SizedBox(height: 24),
                      Text('Check your email',
                          style: Theme.of(context).textTheme.headlineLarge)
                          .animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 12),
                      Text(
                        'We sent a reset link to\n${_emailController.text}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 14),
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text('Back to Sign In',
                            style: TextStyle(
                                color: AppTheme.sage,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                      ).animate().fadeIn(delay: 400.ms),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}