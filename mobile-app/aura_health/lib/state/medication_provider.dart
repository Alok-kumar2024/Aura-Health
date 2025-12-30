import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String timing;
  final String schedule;

  Medication({
    required this.id, required this.name, required this.dosage,
    required this.timing, required this.schedule,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, 'name': name, 'dosage': dosage,
      'timing': timing, 'schedule': schedule,
    };
  }

  factory Medication.fromMap(Map<dynamic, dynamic> map) {
    return Medication(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      timing: map['timing'] ?? '',
      schedule: map['schedule'] ?? '',
    );
  }
}

class MedicationNotifier extends Notifier<List<Medication>> {
  late Box _box;
  final _firestore = FirebaseFirestore.instance;

  @override
  List<Medication> build() {
    _box = Hive.box('medications');
    return _box.values.map((m) => Medication.fromMap(m as Map)).toList();
  }

  // Firestore path helper
  CollectionReference? get _userMeds {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('prescriptions');
  }

  void refresh() {
    state = _box.values.map((m) => Medication.fromMap(m as Map)).toList();
  }

  Future<void> addMedication(Medication med) async {
    // 1. Local Hive Update (Immediate)
    await _box.put(med.id, med.toMap());
    state = _box.values.map((m) => Medication.fromMap(m as Map)).toList();

    // 2. Firebase Sync (Background)
    try {
      await _userMeds?.doc(med.id).set(med.toMap());
    } catch (e) {
      debugPrint("Firebase Sync Failed: $e");
    }
  }

  Future<void> deleteMedication(String id) async {
    await _box.delete(id);
    state = _box.values.map((m) => Medication.fromMap(m as Map)).toList();

    try {
      await _userMeds?.doc(id).delete();
    } catch (e) {
      debugPrint("Firebase Delete Failed: $e");
    }
  }

  Future<void> deletePrescription(String prescriptionName) async {
    final medsToDelete = state.where((m) => m.schedule == prescriptionName).toList();
    for (var med in medsToDelete) {
      await deleteMedication(med.id);
    }
  }
}

final medicationProvider = NotifierProvider<MedicationNotifier, List<Medication>>(
  MedicationNotifier.new,
);