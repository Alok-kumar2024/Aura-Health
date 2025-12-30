import 'package:aura_heallth/service/local_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileState {
  final String name;
  final String email;
  final String gender;
  final String age;
  final String weight;
  final String height;
  final String bloodGroup;
  final String? imagePath; // <--- 1. NEW FIELD

  ProfileState({
    required this.name,
    required this.email,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.bloodGroup,
    this.imagePath, // <--- 2. ADD TO CONSTRUCTOR
  });

  // 3. CHANGE INPUT TO 'Map<String, dynamic>' for safety
  factory ProfileState.fromMap(Map<String, dynamic> map) {
    return ProfileState(
      name: map['name'] ?? "User",
      email: map['email'] ?? "--",
      gender: map['gender'] ?? "--",
      age: map['age'] ?? "--",
      weight: map['weight'] ?? "--",
      height: map['height'] ?? "--",
      bloodGroup: map['bloodGroup'] ?? "--",
      // 4. MAP THE IMAGE KEY (Must match LocalStorageService key)
      imagePath: map['profile_img_path'],
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    return loadProfile();
  }

  ProfileState loadProfile() {
    final data = LocalStorageService().getProfile();
    return ProfileState.fromMap(data);
  }

  void refresh() {
    state = loadProfile();
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});