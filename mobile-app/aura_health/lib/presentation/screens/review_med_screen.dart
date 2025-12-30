import 'package:flutter/material.dart';
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
    _meds = List.from(widget.extractedMeds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Medications")),
      body: ListView.builder(
        itemCount: _meds.length,
        itemBuilder: (context, index) {
          final m = _meds[index];
          return ListTile(
            leading: const Icon(Icons.medication),
            title: Text(m['name'] ?? "Unknown"),
            subtitle: Text("${m['dosage']} | ${m['timing']}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => setState(() => _meds.removeAt(index)),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: () {
            for (var m in _meds) {
              ref.read(medicationProvider.notifier).addMedication(
                Medication(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  name: m['name'],
                  dosage: m['dosage'],
                  timing: m['timing'],
                  schedule: "Today",
                ),
              );
            }
            Navigator.pop(context);
          },
          child: const Text("Save to Profile", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}