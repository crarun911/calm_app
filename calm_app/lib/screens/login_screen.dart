import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signIn(
        _emailController.text,
        _passwordController.text,
      );
      // AuthWrapper will automatically navigate to home
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.midnight,
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -100, left: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.sage.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 50, right: -80,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.lavender.withOpacity(0.06),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // ── Logo / Brand ──────────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.sageGradient,
                              boxShadow: AppTheme.glowSage,
                            ),
                            child: const Center(
                              child: Text('🧘', style: TextStyle(fontSize: 36)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Welcome back',
                              style: Theme.of(context).textTheme.displayMedium),
                          const SizedBox(height: 8),
                          const Text('Sign in to continue your practice',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 14)),
                        ],
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.1),
                    ),

                    const SizedBox(height: 48),

                    // ── Email Field ───────────────────────────────────
                    _InputLabel(label: 'Email'),
                    const SizedBox(height: 8),
                    _AuthTextField(
                      controller: _emailController,
                      hint: 'you@example.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.05),

                    const SizedBox(height: 20),

                    // ── Password Field ────────────────────────────────
                    _InputLabel(label: 'Password'),
                    const SizedBox(height: 8),
                    _AuthTextField(
                      controller: _passwordController,
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppTheme.textSecondary,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required';
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.05),

                    const SizedBox(height: 12),

                    // ── Forgot Password ───────────────────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen())),
                        child: const Text('Forgot password?',
                            style: TextStyle(
                                color: AppTheme.sage,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ),
                    ).animate().fadeIn(delay: 350.ms),

                    const SizedBox(height: 24),

                    // ── Error Message ─────────────────────────────────
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
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
                      ).animate().fadeIn().shake(),

                    if (_errorMessage != null) const SizedBox(height: 16),

                    // ── Sign In Button ────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: GestureDetector(
                        onTap: _isLoading ? null : _signIn,
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
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Sign In',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 32),

                    // ── Divider ───────────────────────────────────────
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppTheme.divider)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('or',
                              style: TextStyle(
                                  color: AppTheme.textMuted, fontSize: 13)),
                        ),
                        Expanded(child: Divider(color: AppTheme.divider)),
                      ],
                    ).animate().fadeIn(delay: 450.ms),

                    const SizedBox(height: 32),

                    // ── Sign Up Link ──────────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(
                              builder: (_) => const SignupScreen())),
                        child: RichText(
                          text: const TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                    color: AppTheme.sage,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Widgets ──────────────────────────────────────────────────────────

class _InputLabel extends StatelessWidget {
  final String label;
  const _InputLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500));
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const _AuthTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 15),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        suffixIcon: suffixIcon,
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
          borderSide: BorderSide(color: AppTheme.sage, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.rose, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.rose, width: 1.5),
        ),
        errorStyle: const TextStyle(color: AppTheme.rose, fontSize: 12),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
