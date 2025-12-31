  import 'dart:async';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';

  import '../service/local_storage_service.dart';
import 'home_provider.dart';

  class AppUser {
    final String uid;
    final String name;
    final String email;

    AppUser({required this.uid, required this.name, required this.email});
  }

  class AuthNotifier extends AsyncNotifier<AppUser?> {
    @override
    FutureOr<AppUser?> build() {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return AppUser(
          uid: user.uid,
          email: user.email!,
          name: user.displayName ?? "User",
        );
      }
      return null;
    }

    Future<void> login(String email, String password) async {
      if (email.isEmpty || !email.contains('@')) {
        state = AsyncValue.error("Please enter a valid email address.", StackTrace.current);
        return;
      }
      if (password.isEmpty) {
        state = AsyncValue.error("Please enter your password.", StackTrace.current);
        return;
      }

      state = const AsyncValue.loading();

      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        state = AsyncValue.data(AppUser(
          uid: credential.user!.uid,
          email: credential.user!.email!,
          name: credential.user!.displayName ?? "User",
        ));
      } on FirebaseAuthException catch (e) {
        String msg = "Login failed.";
        if (e.code == 'user-not-found') msg = "No user found for that email.";
        if (e.code == 'wrong-password') msg = "Wrong password provided.";
        if (e.code == 'invalid-credential') msg = "Invalid email or password.";
        state = AsyncValue.error(msg, StackTrace.current);
      } catch (e, stack) {
        state = AsyncValue.error(e.toString(), stack);
      }
    }

    Future<void> register(String email, String password, String name) async {
      if (name.isEmpty) {
        state = AsyncValue.error("Please enter your name.", StackTrace.current);
        return;
      }
      if (email.isEmpty || !email.contains('@')) {
        state = AsyncValue.error("Please enter a valid email address.", StackTrace.current);
        return;
      }
      if (password.length < 6) {
        state = AsyncValue.error("Password must be at least 6 characters.", StackTrace.current);
        return;
      }

      state = const AsyncValue.loading();
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await credential.user!.updateDisplayName(name);
        await credential.user!.reload();

        state = AsyncValue.data(AppUser(
          uid: credential.user!.uid,
          email: credential.user!.email!,
          name: name,
        ));
      } on FirebaseAuthException catch (e) {
        String msg = "Registration failed.";
        if (e.code == 'email-already-in-use') msg = "This email is already registered.";
        if (e.code == 'weak-password') msg = "Password is too weak.";
        state = AsyncValue.error(msg, StackTrace.current);
      } catch (e, stack) {
        state = AsyncValue.error(e.toString(), stack);
      }
    }

    Future<void> resetPassword([String? email]) async {
      final targetEmail = email ?? state.value?.email;

      if (targetEmail == null || targetEmail.isEmpty) {
        state = AsyncValue.error("No email address provided.", StackTrace.current);
        return;
      }

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: targetEmail);
        // Maintain state if user is logged out
        if (state.value == null) {
          state = const AsyncValue.data(null);
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'invalid-email':
            errorMessage = "The email address is badly formatted.";
            break;
          case 'user-not-found':
          // Note: This code may not trigger if "Email Enumeration Protection" is ON in Firebase Console
            errorMessage = "No account found with this email.";
            break;
          case 'network-request-failed':
            errorMessage = "Check your internet connection and try again.";
            break;
          case 'too-many-requests':
            errorMessage = "Too many attempts. Please try again later.";
            break;
          default:
            errorMessage = "An unexpected error occurred. Please try again.";
        }
        state = AsyncValue.error(errorMessage, StackTrace.current);
        rethrow; // So the UI Dialog can catch it and stop the loading spinner
      } catch (e, stack) {
        state = AsyncValue.error("Error: ${e.toString()}", stack);
        rethrow;
      }
    }



    Future<void> logout() async {
      state = const AsyncValue.loading();
      try {
        // 1. Wipe local Hive data
        await LocalStorageService().clearAll();

        ref.read(bottomProvider.notifier).goToNextScreen(BottomNavigator.HOME);
        // 2. Sign out from Firebase
        await FirebaseAuth.instance.signOut();

        state = const AsyncValue.data(null);
      } catch (e, stack) {
        state = AsyncValue.error(e.toString(), stack);
      }
    }
  }

  final authProvider = AsyncNotifierProvider<AuthNotifier, AppUser?>(() => AuthNotifier());