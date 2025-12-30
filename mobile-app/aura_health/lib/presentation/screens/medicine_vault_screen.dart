import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../state/medication_provider.dart';

class MedicationVaultScreen extends ConsumerStatefulWidget {
  const MedicationVaultScreen({super.key});

  @override
  ConsumerState<MedicationVaultScreen> createState() => _MedicationVaultScreenState();
}

class _MedicationVaultScreenState extends ConsumerState<MedicationVaultScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final medications = ref.watch(medicationProvider);

    // 1. Filter logic for Search
    final filteredMeds = medications.where((med) {
      final nameMatch = med.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final categoryMatch = med.schedule.toLowerCase().contains(_searchQuery.toLowerCase());
      return nameMatch || categoryMatch;
    }).toList();

    // 2. Grouping logic
    final groupedMeds = groupBy(filteredMeds, (Medication m) => m.schedule);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Medication Vault",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: medications.isEmpty
                ? _buildEmptyState(
              icon: Icons.inventory_2_outlined,
              title: "Your vault is empty",
              sub: "Upload a prescription to see it here",
            )
                : filteredMeds.isEmpty
                ? _buildEmptyState(
              icon: Icons.search_off_rounded,
              title: "No results found",
              sub: "Try searching for a different name",
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: groupedMeds.keys.length,
              itemBuilder: (context, index) {
                String category = groupedMeds.keys.elementAt(index);
                List<Medication> items = groupedMeds[category]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryHeader(category, items.length),
                    const SizedBox(height: 12),
                    ...items.map((med) => _buildMedItem(context, ref, med)),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      color: Colors.white,
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: "Search medicine or prescription name...",
          prefixIcon: const Icon(Icons.search, color: Color(0xFF1E88E5)),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.folder_copy_rounded, color: Color(0xFF1E88E5), size: 18),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: Colors.blueGrey,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "$count items",
                style: const TextStyle(fontSize: 10, color: Color(0xFF1E88E5), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        // Bulk Delete for this specific prescription group
        // TextButton(
        //   onPressed: () => _showDeleteGroupDialog(title),
        //   child: const Text("Delete All", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
        // )
      ],
    );
  }

  Widget _buildMedItem(BuildContext context, WidgetRef ref, Medication med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.medication_liquid_rounded, color: Color(0xFF1E88E5), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 2),
                Text("${med.dosage} • ${med.timing}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade300, size: 22),
            onPressed: () => ref.read(medicationProvider.notifier).deleteMedication(med.id),
          )
        ],
      ),
    );
  }

  void _showDeleteGroupDialog(String categoryName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Prescription?"),
        content: Text("Are you sure you want to delete all medications under '$categoryName'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              ref.read(medicationProvider.notifier).deletePrescription(categoryName);
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String sub}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(sub, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}