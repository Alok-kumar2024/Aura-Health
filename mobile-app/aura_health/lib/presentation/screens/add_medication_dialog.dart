import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text("New Medication", style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Medicine Name", hintText: "e.g., Amoxicillin"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _doseController,
              decoration: const InputDecoration(labelText: "Dosage", hintText: "e.g., 500mg"),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedTiming,
              items: ["Before Meal", "After Meal", "With Meal", "Empty Stomach"]
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedTiming = val!),
              decoration: const InputDecoration(labelText: "Timing"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              final newMed = Medication(
                id: DateTime.now().toString(),
                name: _nameController.text,
                dosage: _doseController.text,
                timing: _selectedTiming,
                schedule: "Manual", // Default for now
              );
              ref.read(medicationProvider.notifier).addMedication(newMed);
              Navigator.pop(context);
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}