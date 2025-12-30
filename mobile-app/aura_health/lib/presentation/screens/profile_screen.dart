import 'package:aura_heallth/presentation/screens/settings_screen.dart';
import 'package:aura_heallth/presentation/widgets/user_avatar.dart';
import 'package:aura_heallth/state/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the Hive Data source
    final profile = ref.watch(profileProvider);

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
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
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
            // 1. IDENTITY HEADER (With Smart Avatar)
            ProfileHeader(
              name: profile.name,
              email: profile.email,
              bloodGroup: profile.bloodGroup,
              imagePath: profile.imagePath,
              onEditTap: () {
                // Navigate to Settings or Edit Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
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

            // 3. MEDICAL RECORDS
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

// --- WIDGETS ---

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
    required this.imagePath,
    required this.onEditTap,
  });

  // Helper to get initials (e.g. "John Doe" -> "JD")
  // String getInitials(String name) {
  //   if (name.isEmpty) return "U";
  //   List<String> nameParts = name.trim().split(" ");
  //   if (nameParts.length > 1) {
  //     return "${nameParts[0][0]}${nameParts[1][0]}".toUpperCase();
  //   }
  //   return nameParts[0][0].toUpperCase();
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          // SMART AVATAR
          Stack(
            children: [
              UserAvatar(
                imagePath: imagePath,
                name: name,
                radius: 35,
                fontSize: 22,
              ),
              // CircleAvatar(
              //   radius: 35,
              //   backgroundColor: const Color(0xFFE3F2FD),
              //   child: Text(
              //     getInitials(name),
              //     style: const TextStyle(
              //         fontSize: 24,
              //         fontWeight: FontWeight.bold,
              //         color: Color(0xFF1E88E5)
              //     ),
              //   ),
              // ),
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

          // TEXT DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : "Guest User",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  email.isNotEmpty ? email : "No Email",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9), // Light Green bg
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Blood Group: $bloodGroup",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              fontSize: 20, // Slightly adjusted for fit
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E88E5),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            "$label ($unit)",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

// --- PRESCRIPTION & HOSPITAL CARDS (No Changes needed, keep them as they are) ---
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
          _buildActionButton(
            context,
            label: "Upload\nFile",
            icon: Icons.upload_file_rounded,
            onTap: () {},
          ),
          _buildActionButton(
            context,
            label: "Add\nManually",
            icon: Icons.edit_note_rounded,
            onTap: () {},
          ),
          _buildPrescriptionItem("Feb 12", "Dr. Smith"),
          _buildPrescriptionItem("Jan 28", "Dermatology"),
        ],
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF1E88E5).withOpacity(0.5),
            width: 1.5,
            style: BorderStyle.solid,
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
            child: const Icon(
              Icons.description_outlined,
              color: Colors.orange,
              size: 20,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doc,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
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
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hospital Connect",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Sync with Apollo Hospitals",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Connect",
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
