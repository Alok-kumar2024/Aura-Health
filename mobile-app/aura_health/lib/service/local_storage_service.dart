import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  // Use the same box name we opened in main.dart
  static const String _boxName = 'app_data';

  // --- KEYS ---
  static const String keyName = 'user_name';
  static const String keyEmail = 'user_email';
  static const String keyGender = 'profile_gender';
  static const String keyAge = 'profile_age';
  static const String keyWeight = 'profile_weight';
  static const String keyHeight = 'profile_height';
  static const String keyBloodGroup = 'profile_blood_group';
  static const String keyHasCompletedOnboarding = 'onboarding_complete';
  static const String keyProfileImg = 'profile_img_path';

  // Helper to get the box easily
  Box get _box => Hive.box(_boxName);

  // 1. SAVE BASIC INFO (Used initially after Signup/Login)
  // We don't update Firebase here because this is usually called AFTER
  // Firebase has already done its job (creating the user).
  Future<void> saveBasicUser({required String name, required String email}) async {
    await _box.put(keyName, name);
    await _box.put(keyEmail, email);
  }

  // 2. SAVE VITALS (After Personal Details)
  Future<void> saveVitals({
    required String gender,
    required String age,
    required String weight,
    required String height,
    String? bloodGroup,
  }) async {
    await _box.put(keyGender, gender);
    await _box.put(keyAge, age);
    await _box.put(keyWeight, weight);
    await _box.put(keyHeight, height);

    if (bloodGroup != null) {
      await _box.put(keyBloodGroup, bloodGroup);
    }

    // Mark Onboarding Complete
    await _box.put(keyHasCompletedOnboarding, true);
  }

  // 3. GET PROFILE DATA
  Map<String, dynamic> getProfile() {
    return {
      'name': _box.get(keyName),
      'email': _box.get(keyEmail),
      'gender': _box.get(keyGender),
      'age': _box.get(keyAge),
      'weight': _box.get(keyWeight),
      'height': _box.get(keyHeight),
      'bloodGroup': _box.get(keyBloodGroup),
      'profile_img_path': _box.get(keyProfileImg),
    };
  }

  // 4. UPDATE NAME (For Edit Profile)
  // This updates BOTH Hive (Local) and Firebase (Cloud)
  Future<void> updateName(String name) async {
    // 1. Update Local Hive
    await _box.put(keyName, name);

    // 2. Update Firebase Auth Profile
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updateDisplayName(name);
        await user.reload(); // Refresh user data
      } catch (e) {
        // Even if Firebase fails (offline), we updated local so UI is fine.
        print("Failed to update Firebase name: $e");
      }
    }
  }

  // 5. SAVE IMAGE PATH (For Edit Profile)
  Future<void> saveProfileImage(String path) async {
    await _box.put(keyProfileImg, path);
  }

  // 6. CHECK ONBOARDING STATUS
  bool hasCompletedOnboarding() {
    return _box.get(keyHasCompletedOnboarding, defaultValue: false);
  }

  // 7. CLEAR (Logout)
  Future<void> clearAll() async {
    await _box.clear();
  }
}