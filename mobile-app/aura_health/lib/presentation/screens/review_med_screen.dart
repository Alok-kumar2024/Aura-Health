import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/medication_provider.dart';

class ReviewMedsScreen extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> extractedMeds;
  const ReviewMedsScreen({super.key, required this.extractedMeds});

  @override
  ConsumerState<ReviewMedsScreen> createState() => _ReviewMedsScreenState();
}

class _ReviewMedsScreenState extends ConsumerState<ReviewMedsScreen> {
  late List<Map<String, dynamic>> _meds;

  @override
  void initState() {
    super.initState();
    // Create a mutable copy of the extracted data
    _meds = List<Map<String, dynamic>>.from(
      widget.extractedMeds.map((m) => Map<String, dynamic>.from(m)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Review Prescription",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _meds.isEmpty ? _buildEmptyState() : _buildMedicationList(),
      bottomNavigationBar: _meds.isEmpty ? null : _buildBottomActions(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "No medications detected",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Go Back"),
          )
        ],
      ),
    );
  }

  Widget _buildMedicationList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: _meds.length,
      itemBuilder: (context, index) {
        final m = _meds[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medication_rounded, color: Color(0xFF1E88E5)),
            ),
            title: Text(
              m['name'] ?? "Unknown Medication",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "${m['dosage']} • ${m['timing']}",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              onPressed: () {
                HapticFeedback.mediumImpact();
                setState(() => _meds.removeAt(index));
              },
            ),
            onTap: () => _editMedication(index),
          ),
        );
      },
    );
  }

  // ALLOWS USERS TO FIX AI ERRORS
  void _editMedication(int index) {
    final nameCtrl = TextEditingController(text: _meds[index]['name']);
    final doseCtrl = TextEditingController(text: _meds[index]['dosage']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Medication"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: doseCtrl, decoration: const InputDecoration(labelText: "Dosage")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _meds[index]['name'] = nameCtrl.text;
                _meds[index]['dosage'] = doseCtrl.text;
              });
              Navigator.pop(ctx);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Found ${_meds.length} items in prescription",
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: _saveMedications,
              child: const Text("Save to Medication Vault", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _saveMedications() {
    for (var m in _meds) {
      ref.read(medicationProvider.notifier).addMedication(
        Medication(
          id: DateTime.now().microsecondsSinceEpoch.toString() + m['name'],
          name: m['name'] ?? "Unknown",
          dosage: m['dosage'] ?? "N/A",
          timing: m['timing'] ?? "As needed",
          schedule: "Daily", // Defaulting to daily for vault safety
        ),
      );
    }

    _showSuccessSnackBar();
    Navigator.pop(context);
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Medications added to your vault!"),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}