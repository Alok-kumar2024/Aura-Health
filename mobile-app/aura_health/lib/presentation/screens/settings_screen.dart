import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Mock State Variables
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // Android: Black Icons
          statusBarBrightness: Brightness.light,    // iOS: Black Icons
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. PREFERENCES SECTION
            _buildSectionHeader("App Preferences"),
            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              title: "Push Notifications",
              subtitle: "Receive alerts for critical interactions",
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: "Dark Mode",
              subtitle: "Reduce eye strain at night",
              value: _darkMode,
              onChanged: (val) => setState(() => _darkMode = val),
            ),

            const SizedBox(height: 24),

            // 2. PRIVACY & SECURITY (Crucial for Health Apps)
            _buildSectionHeader("Privacy & Security"),
            _buildSwitchTile(
              icon: Icons.fingerprint,
              title: "Biometric Lock",
              subtitle: "Require FaceID/TouchID to open",
              value: _biometricEnabled,
              onChanged: (val) => setState(() => _biometricEnabled = val),
            ),
            _buildActionTile(
              icon: Icons.download_rounded,
              title: "Export Health Data",
              subtitle: "Download CSV/PDF for your doctor",
              onTap: () {
                // TODO: Implement PDF Export
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Exporting data...")));
              },
            ),
            _buildActionTile(
              icon: Icons.delete_outline_rounded,
              title: "Clear Scan History",
              subtitle: "Permanently delete all local data",
              isDestructive: true,
              onTap: () => _showDeleteConfirmation(context),
            ),

            const SizedBox(height: 24),

            // 3. SUPPORT
            _buildSectionHeader("Support"),
            _buildActionTile(icon: Icons.mail_outline_rounded, title: "Contact Support", onTap: () {}),
            _buildActionTile(icon: Icons.description_outlined, title: "Terms & Privacy Policy", onTap: () {}),

            const SizedBox(height: 40),

            Center(
              child: Text(
                "Version 1.0.0 (Beta)",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF1E88E5),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFF1E88E5).withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF1E88E5), size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final color = isDestructive ? Colors.red : Colors.black87;
    final iconColor = isDestructive ? Colors.red : const Color(0xFF1E88E5);
    final bgColor = isDestructive ? Colors.red.withOpacity(0.1) : const Color(0xFF1E88E5).withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: color)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Clear History?"),
        content: const Text("This will permanently delete all your scanned meals and interaction logs. This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              // TODO: Call Provider to clear list
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}