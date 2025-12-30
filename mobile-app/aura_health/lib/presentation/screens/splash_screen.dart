import 'package:aura_heallth/presentation/screens/home_screen.dart'; // Update path
import 'package:aura_heallth/presentation/screens/personal_details_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../service/local_storage_service.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatusAndNavigate();
  }

  Future<void> _checkStatusAndNavigate() async {
    // 1. Artificial Delay (Optional: Keeps logo visible for 2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 2. Check Authentication
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // CASE A: No User -> Login Screen
      _navigateTo(const LoginScreen());
    } else {
      // CASE B: User Logged In -> Check Onboarding Status
      // We check Hive to see if they finished the Personal Details setup
      final hasCompletedOnboarding = LocalStorageService().hasCompletedOnboarding();

      if (hasCompletedOnboarding) {
        // All Good -> Home
        _navigateTo(const HomeScreen());
      } else {
        // Missing Info -> Personal Details
        _navigateTo(const PersonalDetailsScreen());
      }
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Force status bar transparent for full-screen effect
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. LOGO ANIMATION (Scale or Fade could be added here)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded,
                  size: 80,
                  color: Color(0xFF1E88E5),
                ),
              ),

              const SizedBox(height: 24),

              // 2. APP NAME
              const Text(
                "Aura Health",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 48),

              // 3. LOADING INDICATOR
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Color(0xFF1E88E5),
                  strokeWidth: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}