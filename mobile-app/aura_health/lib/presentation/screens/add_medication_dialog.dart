import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/medication_provider.dart';

class AddMedicationDialog extends ConsumerStatefulWidget {
  const AddMedicationDialog({super.key});

  @override
  ConsumerState<AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends ConsumerState<AddMedicationDialog> {
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  String _selectedTiming = "After Meal";
  String _selectedSchedule = "Daily"; // Added schedule selection

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medical_services_rounded, color: Color(0xFF1E88E5), size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            "Add Medication",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.black87),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Medicine Name"),
            _buildTextField(
              controller: _nameController,
              hint: "e.g., Amoxicillin",
              icon: Icons.medication_rounded,
            ),
            const SizedBox(height: 20),
            _buildLabel("Dosage"),
            _buildTextField(
              controller: _doseController,
              hint: "e.g., 500mg",
              icon: Icons.monitor_weight_rounded,
            ),
            const SizedBox(height: 20),
            _buildLabel("Instruction"),
            _buildDropdown(
              value: _selectedTiming,
              items: ["Before Meal", "After Meal", "With Meal", "Empty Stomach"],
              icon: Icons.access_time_filled_rounded,
              onChanged: (val) => setState(() => _selectedTiming = val!),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _handleSave,
                child: const Text("Save Med", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- LOGIC ---

  void _handleSave() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a medicine name")),
      );
      return;
    }

    HapticFeedback.lightImpact();

    final newMed = Medication(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      dosage: _doseController.text.trim().isEmpty ? "N/A" : _doseController.text.trim(),
      timing: _selectedTiming,
      schedule: _selectedSchedule,
    );

    ref.read(medicationProvider.notifier).addMedication(newMed);
    Navigator.pop(context);
  }

  // --- WIDGET HELPERS ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon}) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF1E88E5), size: 20),
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required IconData icon, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1E88E5)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF1E88E5), size: 20),
            border: InputBorder.none,
          ),
          items: items.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}