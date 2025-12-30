import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

class LocalStorageService {
  // Use the same box name opened in main.dart
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

  // Firestore Instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper to get current user document reference
  DocumentReference? get _userDoc {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid != null ? _firestore.collection('users').doc(uid) : null;
  }

  // 1. SAVE BASIC INFO (Used initially after Signup/Login)
  Future<void> saveBasicUser({required String name, required String email}) async {
    await _box.put(keyName, name);
    await _box.put(keyEmail, email);

    // Sync to Firestore
    try {
      await _userDoc?.set({
        'name': name,
        'email': email,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Failed to sync basic info: $e");
    }
  }

  // 2. SAVE VITALS (After Personal Details)
  Future<void> saveVitals({
    required String gender,
    required String age,
    required String weight,
    required String height,
    String? bloodGroup,
  }) async {
    // A. Save to Local Hive (Immediate UI update)
    await _box.put(keyGender, gender);
    await _box.put(keyAge, age);
    await _box.put(keyWeight, weight);
    await _box.put(keyHeight, height);
    if (bloodGroup != null) await _box.put(keyBloodGroup, bloodGroup);
    await _box.put(keyHasCompletedOnboarding, true);

    // B. Sync to Cloud Firestore (Background backup)
    try {
      await _userDoc?.set({
        'gender': gender,
        'age': age,
        'weight': weight,
        'height': height,
        if (bloodGroup != null) 'bloodGroup': bloodGroup,
        'onboarding_complete': true,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Failed to sync vitals to Firestore: $e");
    }
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
  Future<void> updateName(String name) async {
    // 1. Update Local Hive
    await _box.put(keyName, name);

    // 2. Update Firebase Auth Profile & Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updateDisplayName(name);
        await _userDoc?.update({
          'name': name,
          'last_updated': FieldValue.serverTimestamp(),
        });
        await user.reload();
      } catch (e) {
        debugPrint("Failed to update Firebase name: $e");
      }
    }
  }

  // 5. SAVE IMAGE PATH (For Edit Profile)
  Future<void> saveProfileImage(String path) async {
    await _box.put(keyProfileImg, path);

    // Note: Usually, you'd upload the actual file to Firebase Storage
    // and save the URL in Firestore. For now, we update the local path.
    try {
      await _userDoc?.update({'profile_img_local_path': path});
    } catch (e) {
      debugPrint("Failed to sync image path: $e");
    }
  }

  // 6. CHECK ONBOARDING STATUS
  bool hasCompletedOnboarding() {
    return _box.get(keyHasCompletedOnboarding, defaultValue: false);
  }

  // 7. CLEAR (Logout)
  Future<void> clearAll() async {
    // 1. Clear Profile/App Data box
    await _box.clear();

    // 2. Clear Medications box
    final medBox = Hive.box('medications');
    await medBox.clear();

    debugPrint("Local data wiped successfully.");
  }

  // 8. DATA RECOVERY (Pull from Firestore to Hive)
  // Call this after a user logs in on a new device
  Future<void> restoreFromCloud() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      // --- PART A: Restore Profile Details ---
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        await _box.put(keyName, data['name']);
        await _box.put(keyEmail, data['email']);
        await _box.put(keyGender, data['gender']);
        await _box.put(keyAge, data['age']);
        await _box.put(keyWeight, data['weight']);
        await _box.put(keyHeight, data['height']);
        await _box.put(keyBloodGroup, data['bloodGroup']);
        await _box.put(keyHasCompletedOnboarding, data['onboarding_complete'] ?? false);
      }

      // --- PART B: Restore Medications ---
      final medBox = Hive.box('medications');
      final prescriptionsSnap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('prescriptions')
          .get();

      // Clear local medBox before refilling to avoid duplicates if any
      await medBox.clear();

      for (var medDoc in prescriptionsSnap.docs) {
        // Save each document from Firebase into local Hive
        await medBox.put(medDoc.id, medDoc.data());
      }

      debugPrint("Cloud restoration complete: Profile + ${prescriptionsSnap.docs.length} medications.");
    } catch (e) {
      debugPrint("Error during cloud restoration: $e");
    }
  }
}