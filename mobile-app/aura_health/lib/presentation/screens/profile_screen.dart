import 'package:aura_heallth/presentation/screens/settings_screen.dart'; // Import settings
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "My Health Profile",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // The Gear Icon is the ONLY entry point for App Settings now
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. IDENTITY HEADER
            const ProfileHeader(),

            const SizedBox(height: 24),

            // 2. VITALS ROW (New! Replaces the duplicate settings)
            // This makes the profile useful for doctors.
            const Row(
              children: [
                Expanded(child: VitalsCard(label: "Age", value: "24", unit: "yrs")),
                SizedBox(width: 12),
                Expanded(child: VitalsCard(label: "Weight", value: "62", unit: "kg")),
                SizedBox(width: 12),
                Expanded(child: VitalsCard(label: "Height", value: "175", unit: "cm")),
              ],
            ),

            const SizedBox(height: 32),

            // 3. PRESCRIPTION VAULT
            const SectionTitle(title: "Medical Records"),
            const SizedBox(height: 16),
            const PrescriptionVault(),

            const SizedBox(height: 32),

            // 4. HOSPITAL CONNECT
            const SectionTitle(title: "Care Network"),
            const SizedBox(height: 16),
            const HospitalConnectCard(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// --- NEW WIDGET: VITALS CARD ---
class VitalsCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const VitalsCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              children: [
                TextSpan(text: " ($unit)", style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- KEEP THESE WIDGETS FROM PREVIOUS CODE ---
// (Copy ProfileHeader, PrescriptionVault, HospitalConnectCard, SectionTitle exactly as they were)
// I will reprint them below for easy copy-pasting if you need them.

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87));
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(radius: 35, backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=sarah")),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: const Color(0xFF1E88E5), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: const Icon(Icons.edit, size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sarah Johnson", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("ID: #8839201", style: TextStyle(fontSize: 14, color: Colors.grey)),
                SizedBox(height: 4),
                Text("Blood Group: O+", style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PrescriptionVault extends StatelessWidget {
  const PrescriptionVault({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          // ACTION 1: Upload File (Camera/Gallery)
          _buildActionButton(
            context,
            label: "Upload\nFile",
            icon: Icons.upload_file_rounded,
            onTap: () {
              // Trigger Image Picker
            },
          ),

          // ACTION 2: Manual Entry (Type Name)
          _buildActionButton(
            context,
            label: "Add\nManually",
            icon: Icons.edit_note_rounded,
            onTap: () => _showAddManualDialog(context),
          ),

          // Existing Items
          _buildPrescriptionItem("Feb 12", "Dr. Smith"),
          _buildPrescriptionItem("Jan 28", "Dermatology"),
          _buildPrescriptionItem("Dec 15", "Cardio Lab"),
        ],
      ),
    );
  }

  // --- Helper for the Dashed Action Buttons ---
  Widget _buildActionButton(BuildContext context, {required String label, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 100, // Slightly smaller to fit both
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD), // Light Blue
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF1E88E5).withOpacity(0.5),
            width: 1.5,
            style: BorderStyle.solid, // Dashed border indicates "Add New"
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: const Color(0xFF1E88E5)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1E88E5),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper for Existing Items (Same as before) ---
  Widget _buildPrescriptionItem(String date, String doc) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description_outlined, color: Colors.orange, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doc,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- POPUP DIALOG FOR MANUAL ENTRY ---
  void _showAddManualDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Prescription"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Medicine/Prescription Name",
                hintText: "e.g., Metformin 500mg",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "Doctor's Name (Optional)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Add Logic to save to list
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class HospitalConnectCard extends StatelessWidget {
  const HospitalConnectCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF2E7D32).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 28)),
          const SizedBox(width: 16),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Hospital Connect", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(height: 4), Text("Sync with Apollo Hospitals", style: TextStyle(color: Colors.white70, fontSize: 13))])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: const Text("Connect", style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12))),
        ],
      ),
    );
  }
}