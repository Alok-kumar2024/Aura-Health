import 'package:aura_heallth/service/local_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'medication_provider.dart';

class ProfileState {
  final String name;
  final String email;
  final String gender;
  final String age;
  final String weight;
  final String height;
  final String bloodGroup;
  final String? imagePath;

  ProfileState({
    required this.name,
    required this.email,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.bloodGroup,
    this.imagePath,
  });

  // Convert ProfileState to Map for saving to Hive or Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'gender': gender,
      'age': age,
      'weight': weight,
      'height': height,
      'bloodGroup': bloodGroup,
      'profile_img_path': imagePath,
    };
  }

  // Create ProfileState from Map (Hive/Firestore data)
  factory ProfileState.fromMap(Map<String, dynamic> map) {
    return ProfileState(
      name: map['name'] ?? "User",
      email: map['email'] ?? "--",
      gender: map['gender'] ?? "--",
      age: map['age'] ?? "--",
      weight: map['weight'] ?? "--",
      height: map['height'] ?? "--",
      bloodGroup: map['bloodGroup'] ?? "--",
      imagePath: map['profile_img_path'],
    );
  }

  // Helper to copy state with changes
  ProfileState copyWith({
    String? name,
    String? email,
    String? gender,
    String? age,
    String? weight,
    String? height,
    String? bloodGroup,
    String? imagePath,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    return loadProfile();
  }

  // 1. Load data from local Hive via the service
  ProfileState loadProfile() {
    final data = LocalStorageService().getProfile();
    return ProfileState.fromMap(data);
  }

  // 2. Local Refresh (Updates UI from Hive)
  void refresh() {
    state = loadProfile();
  }

  // 3. Cloud Sync (Pulls from Firestore, saves to Hive, then updates UI)
  Future<void> syncFromCloud() async {
    final service = LocalStorageService();

    // 1. Download EVERYTHING from Firestore into the Hive boxes
    await service.restoreFromCloud();

    // 2. Refresh THIS provider (Profile UI)
    state = loadProfile();

    ref.invalidate(medicationProvider);
  }
}

// Global Provider
final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});