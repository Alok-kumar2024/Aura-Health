import 'package:aura_heallth/presentation/screens/sign_up_screen.dart';
import 'package:aura_heallth/presentation/screens/personal_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_provider.dart';
import '../../service/local_storage_service.dart';
import 'home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isHandlingAuth = false;

  // Local state to keep the loader active during cloud data restoration
  bool _isSyncingData = false;

  @override
  void initState() {
    super.initState();
    // Clear any lingering auth errors when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.hasError) {
        ref.read(authProvider.notifier).state = const AsyncValue.data(null);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Combined loading state for UI feedback
    final bool showLoader = authState.isLoading || _isSyncingData;

    // Listen for auth state changes to trigger data sync and navigation
    if (!_isHandlingAuth && authState.isLoading) {
      _isHandlingAuth = true;
    } else if (_isHandlingAuth && !authState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _isHandlingAuth = false;

        if (authState.hasError) {
          _showCustomSnackBar(
            context,
            authState.error.toString(),
            isError: true,
          );
        } else if (authState.value != null) {
          // Keep the loader spinning while we fetch the profile from Firestore
          setState(() => _isSyncingData = true);

          try {
            // 1. Restore the user profile and onboarding status from the cloud
            await LocalStorageService().restoreFromCloud();

            if (!mounted) return;

            // 2. Check if the user has previously completed onboarding
            final bool isComplete = LocalStorageService()
                .hasCompletedOnboarding();

            // 3. Navigate to the appropriate screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => isComplete
                    ? const HomeScreen()
                    : const PersonalDetailsScreen(),
              ),
            );
          } catch (e) {
            _showCustomSnackBar(
              context,
              "Failed to restore profile data.",
              isError: true,
            );
          } finally {
            if (mounted) setState(() => _isSyncingData = false);
          }
        }
      });
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // LOGO SECTION
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E88E5).withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.health_and_safety_rounded,
                          size: 50,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Welcome Back!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // INPUT FIELDS
                    _buildTextField(
                      controller: _emailController,
                      label: "Email Address",
                      icon: Icons.email_outlined,
                      inputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      label: "Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),

                    // FORGOT PASSWORD
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: showLoader
                            ? null
                            : () => _showPasswordResetDialog(context),
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Color(0xFF1E88E5),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // LOGIN BUTTON
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: showLoader ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: showLoader
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                "Sign In",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // SIGN UP NAVIGATION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpScreen(),
                            ),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Color(0xFF1E88E5),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- LOGIC ---

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showCustomSnackBar(
        context,
        "Please enter a valid email address",
        isError: true,
      );
      return;
    }
    if (password.isEmpty) {
      _showCustomSnackBar(context, "Please enter your password", isError: true);
      return;
    }
    await ref.read(authProvider.notifier).login(email, password);
  }

  void _showPasswordResetDialog(BuildContext context) {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showCustomSnackBar(
        context,
        "Enter your email address in the field above first",
        isError: true,
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          // NOTE: Ensure isResetting is declared OUTSIDE the builder if using a simple StatefulBuilder
          // or use a local variable managed by setDialogState.
          bool isResetting = false;

          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // THEMED ICON CONTAINER
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.alternate_email_rounded,
                    color: Color(0xFF1E88E5),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Reset Password",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                    children: [
                      const TextSpan(text: "We will send a secure link to "),
                      TextSpan(
                        text: email,
                        style: const TextStyle(
                          color: Color(0xFF1E88E5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ". Please follow the link to set a new password."),
                    ],
                  ),
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: isResetting ? null : () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: isResetting
                          ? null
                          : () async {
                        setDialogState(() => isResetting = true);
                        try {
                          await ref.read(authProvider.notifier).resetPassword(email);
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            _showCustomSnackBar(
                              context,
                              "Reset link sent! Check your email.",
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            _showCustomSnackBar(context, e.toString(), isError: true);
                          }
                        } finally {
                          // Use a local state check if needed
                          setDialogState(() => isResetting = false);
                        }
                      },
                      child: isResetting
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        "Send Link",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCustomSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? inputType,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      keyboardType: inputType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
      ),
    );
  }
}
