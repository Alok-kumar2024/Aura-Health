import 'package:aura_heallth/presentation/screens/settings_screen.dart';
import 'package:aura_heallth/presentation/widgets/user_avatar.dart';
import 'package:aura_heallth/state/profile_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart'; // Ensure you added this to pubspec.yaml

import '../../service/ml_service.dart';
import '../../state/medication_provider.dart';
import 'add_medication_dialog.dart';
import 'medicine_vault_screen.dart';
import 'review_med_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "My Health Profile",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. IDENTITY HEADER
            ProfileHeader(
              name: profile.name,
              email: profile.email,
              bloodGroup: profile.bloodGroup,
              imagePath: profile.imagePath,
              onEditTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),

            const SizedBox(height: 24),

            // 2. VITALS ROW
            Row(
              children: [
                Expanded(
                  child: VitalsCard(
                    label: "Age",
                    value: profile.age.isNotEmpty ? profile.age : "--",
                    unit: "yrs",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: VitalsCard(
                    label: "Weight",
                    value: profile.weight.isNotEmpty ? profile.weight : "--",
                    unit: "kg",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: VitalsCard(
                    label: "Height",
                    value: profile.height.isNotEmpty ? profile.height : "--",
                    unit: "cm",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 3. MEDICAL RECORDS (PRESCRIPTION VAULT)
            const SectionTitle(title: "Prescription Vault"),
            const SizedBox(height: 16),
            const PrescriptionVault(),

            const SizedBox(height: 32),

            // 4. HOSPITAL CONNECT
            // const SectionTitle(title: "Care Network"),
            // const SizedBox(height: 16),
            // const HospitalConnectCard(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS ---

class PrescriptionVault extends ConsumerWidget {
  const PrescriptionVault({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationProvider);

    // Grouping medications by Prescription Name (schedule field)
    final groupedMeds = groupBy(medications, (Medication m) => m.schedule);

    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildActionButton(
            context,
            label: "Upload\nPrescription",
            icon: Icons.document_scanner_rounded,
            onTap: () => _handleFileUpload(context, ref),
          ),
          _buildActionButton(
            context,
            label: "Add\nManually",
            icon: Icons.edit_note_rounded,
            onTap: () => showDialog(
              context: context,
              builder: (context) => const AddMedicationDialog(),
            ),
          ),
          // Show categorized folders
          ...groupedMeds.entries.map(
            (entry) => _buildPrescriptionFolder(
              context,
              name: entry.key,
              count: entry.value.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionFolder(
    BuildContext context, {
    required String name,
    required int count,
  }) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MedicationVaultScreen()),
      ),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_copy_rounded,
                color: Colors.orange,
                size: 22,
              ),
            ),
            const Spacer(),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              "$count Medications",
              style: const TextStyle(
                fontSize: 11,
                color: Colors.blueGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Inside PrescriptionVault widget
  // Inside PrescriptionVault widget in profile_screen.dart

  Future<void> _handleFileUpload(BuildContext context, WidgetRef ref) async {
    // 1. Only allow Images for the Custom ML Model
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      _showLoadingDialog(context);

      try {
        // 2. Call the Render API
        final results = await ref
            .read(mlServiceProvider)
            .extractMeds(file.bytes!, 'image/jpeg');

        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog

          if (results.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No drugs detected. Please try a clearer photo.")),
            );
          } else {
            // 3. Move to Review Screen where user can edit Dosage/Timing
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReviewMedsScreen(extractedMeds: results),
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) Navigator.pop(context);
        print("Upload Error: $e");
      }
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF1E88E5)),
            SizedBox(height: 20),
            Text(
              "AI is scanning your document...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF1E88E5).withOpacity(0.2)),
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
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String bloodGroup;
  final String? imagePath;
  final VoidCallback onEditTap;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.bloodGroup,
    this.imagePath,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              UserAvatar(
                imagePath: imagePath,
                name: name,
                radius: 35,
                fontSize: 22,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onEditTap,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : "User",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  email.isNotEmpty ? email : "No Email",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Blood Group: $bloodGroup",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E88E5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "$label ($unit)",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// class HospitalConnectCard extends StatelessWidget {
//   const HospitalConnectCard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(22),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF2E7D32).withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.local_hospital_rounded,
//               color: Colors.white,
//               size: 28,
//             ),
//           ),
//           const SizedBox(width: 16),
//           const Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Hospital Connect",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w900,
//                     fontSize: 16,
//                   ),
//                 ),
//                 Text(
//                   "Sync with Apollo Hospitals",
//                   style: TextStyle(color: Colors.white70, fontSize: 13),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: const Text(
//               "Connect",
//               style: TextStyle(
//                 color: Color(0xFF2E7D32),
//                 fontWeight: FontWeight.w900,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: Colors.black87,
      ),
    );
  }
}
