import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signUp(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
      );
      // AuthWrapper handles navigation
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
          Positioned(
            top: -80, right: -80,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.lavender.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 100, left: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.sage.withOpacity(0.05),
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
                    const SizedBox(height: 20),

                    // Back button
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

                    const SizedBox(height: 32),

                    Text('Create account',
                        style: Theme.of(context).textTheme.displayMedium)
                        .animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 8),
                    const Text('Start your mindfulness journey today',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 14))
                        .animate().fadeIn(delay: 150.ms),

                    const SizedBox(height: 36),

                    // Name
                    _label('Full Name'),
                    const SizedBox(height: 8),
                    _field(
                      controller: _nameController,
                      hint: 'Your name',
                      icon: Icons.person_outline_rounded,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Name is required' : null,
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.05),

                    const SizedBox(height: 16),

                    // Email
                    _label('Email'),
                    const SizedBox(height: 8),
                    _field(
                      controller: _emailController,
                      hint: 'you@example.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ).animate().fadeIn(delay: 250.ms).slideX(begin: -0.05),

                    const SizedBox(height: 16),

                    // Password
                    _label('Password'),
                    const SizedBox(height: 8),
                    _field(
                      controller: _passwordController,
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppTheme.textSecondary, size: 20,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required';
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.05),

                    const SizedBox(height: 16),

                    // Confirm Password
                    _label('Confirm Password'),
                    const SizedBox(height: 8),
                    _field(
                      controller: _confirmController,
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscureConfirm,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppTheme.textSecondary, size: 20,
                        ),
                        onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Please confirm password';
                        if (v != _passwordController.text)
                          return 'Passwords do not match';
                        return null;
                      },
                    ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.05),

                    const SizedBox(height: 24),

                    // Error
                    if (_errorMessage != null) ...[
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
                      const SizedBox(height: 16),
                    ],

                    // Sign Up button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: GestureDetector(
                        onTap: _isLoading ? null : _signUp,
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
                                : const Text('Create Account',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 24),

                    // Login link
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen())),
                        child: RichText(
                          text: const TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
                                    color: AppTheme.sage,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 450.ms),

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

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
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
          borderSide: const BorderSide(color: AppTheme.sage, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.rose, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.rose, width: 1.5),
        ),
        errorStyle: const TextStyle(color: AppTheme.rose, fontSize: 12),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
