import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!success && mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
    // Navigation is handled by auth state listener in main.dart
  }

  void _signInWithGoogle() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (!success && mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _continueAsGuest() async {
    final auth = context.read<AuthProvider>();
    await auth.continueAsGuest();
    // Navigation is handled by auth state listener in main.dart
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // Ambient Background Gradients (matching HTML design)
          Positioned(
            top: -size.height * 0.1,
            left: -size.width * 0.1,
            child: Container(
              width: size.width * 0.6,
              height: size.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.2,
            right: -size.width * 0.1,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header Illustration Area
                  SizedBox(
                    height: size.height * 0.32,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.primary.withValues(alpha: 0.2),
                                  theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Icon(
                            Icons.psychology_rounded,
                            size: 80,
                            color: theme.colorScheme.primary.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Sheet Content
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(48),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                          blurRadius: 32,
                          offset: const Offset(0, -8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Brand Header
                          Text(
                            'Moodify',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Track your mood. Improve your mind.',
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Email Input
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!v.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Email Address',
                              prefixIcon: Icon(
                                Icons.mail_outline_rounded,
                                size: 20,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password Input
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Password',
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                size: 20,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _showComingSoon(),
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primaryContainer,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(9999),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                    blurRadius: 32,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: auth.isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                ),
                                child: auth.isLoading
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Login',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: theme.colorScheme.onPrimary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 20,
                                            color: theme.colorScheme.onPrimary,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR CONTINUE WITH',
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Google Sign In
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              onPressed: _signInWithGoogle,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: theme.colorScheme.surfaceContainerLowest,
                                side: BorderSide(
                                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.g_mobiledata,
                                    size: 28,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Sign in with Google',
                                    style: GoogleFonts.manrope(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Guest Mode
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: TextButton(
                              onPressed: _continueAsGuest,
                              style: TextButton.styleFrom(
                                backgroundColor: theme.colorScheme.surfaceContainerLow,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_outline_rounded,
                                    size: 20,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Continue as Guest',
                                    style: GoogleFonts.manrope(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Sign Up Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SignupScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Feature coming soon!',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
