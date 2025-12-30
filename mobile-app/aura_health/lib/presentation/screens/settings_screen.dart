import 'package:aura_heallth/presentation/screens/personal_details_screen.dart';
import 'package:aura_heallth/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../service/local_storage_service.dart';
import '../../state/profile_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
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
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ACCOUNT
            _buildSectionHeader("Account"),
            _buildActionTile(
              icon: Icons.person_outline_rounded,
              title: "Edit Profile",
              subtitle: "Name, Age, Weight, Blood Group",
              onTap: () {
                final currentProfile = ref.read(profileProvider);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // We pass 'existingProfile' to trigger Edit Mode
                    builder: (_) => PersonalDetailsScreen(existingProfile: currentProfile),
                  ),
                );
              }
            ),
            _buildActionTile(
              icon: Icons.lock_outline_rounded,
              title: "Change Password",
              onTap: () {
                // Trigger Password Reset Email
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password reset email sent"))
                );
              },
            ),

            const SizedBox(height: 24),

            // 2. PREFERENCES
            _buildSectionHeader("Preferences"),
            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              title: "Push Notifications",
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: "Dark Mode",
              value: _darkMode,
              onChanged: (val) => setState(() => _darkMode = val),
            ),

            const SizedBox(height: 24),

            // 3. SECURITY & DATA
            _buildSectionHeader("Security & Data"),
            _buildSwitchTile(
              icon: Icons.fingerprint,
              title: "Biometric Lock",
              subtitle: "FaceID / TouchID",
              value: _biometricEnabled,
              onChanged: (val) => setState(() => _biometricEnabled = val),
            ),
            _buildActionTile(
              icon: Icons.download_rounded,
              title: "Export Health Data",
              onTap: () {},
            ),
            _buildActionTile(
              icon: Icons.cleaning_services_rounded,
              title: "Clear App Cache",
              onTap: () => _showClearCacheDialog(context),
            ),

            const SizedBox(height: 24),

            // 4. SUPPORT & LEGAL (New Section)
            _buildSectionHeader("Support & Legal"),
            _buildActionTile(
              icon: Icons.help_outline_rounded,
              title: "Help Center",
              onTap: () {}, // Navigate to Help FAQ
            ),
            _buildActionTile(
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              onTap: () => _showLegalDialog(context, "Privacy Policy", _privacyPolicyText),
            ),
            _buildActionTile(
              icon: Icons.description_outlined,
              title: "Terms of Service",
              onTap: () => _showLegalDialog(context, "Terms of Service", _termsText),
            ),
            _buildActionTile(
              icon: Icons.star_rate_rounded,
              title: "Rate Us",
              onTap: () {}, // Open Store Link
            ),

            const SizedBox(height: 24),

            // 5. DANGER ZONE
            _buildSectionHeader("Danger Zone"),
            _buildActionTile(
              icon: Icons.no_accounts_rounded,
              title: "Delete Account",
              subtitle: "Permanently delete your account",
              isDestructive: true,
              onTap: () => _showDeleteAccountDialog(context),
            ),

            const SizedBox(height: 40),

            // 6. LOGOUT
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  side: BorderSide(color: Colors.red.shade200),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Log Out", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // VERSION
            Center(
              child: Column(
                children: [
                  Text(
                    "Aura Health",
                    style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "v1.0.0 (Beta Build 102)",
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- ACTIONS & DIALOGS ---

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Log Out?"),
        content: const Text("Are you sure you want to sign out? You will need to login again to access your data."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await LocalStorageService().clearAll();
              await ref.read(authProvider.notifier).logout();

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
            child: const Text("Log Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("This is a permanent action. All your health data will be wiped immediately. This cannot be undone."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              // TODO: Call API to delete user
              Navigator.pop(ctx);
            },
            child: const Text("Delete Forever", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cache Cleared Successfully")));
  }

  void _showLegalDialog(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Text(content, style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87)),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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

  // --- DUMMY LEGAL TEXT ---
  final String _privacyPolicyText = """
**Privacy Policy**

Your privacy is important to us. It is Aura Health's policy to respect your privacy regarding any information we may collect from you across our application.

1. **Information we collect**
We only ask for personal information when we truly need it to provide a service to you. We collect it by fair and lawful means, with your knowledge and consent.

2. **How we store data**
We only retain collected information for as long as necessary to provide you with your requested service. What data we store, we’ll protect within commercially acceptable means to prevent loss and theft.

3. **Sharing of data**
We don't share any personally identifying information publicly or with third-parties, except when required to by law.

4. **Your rights**
You are free to refuse our request for your personal information, with the understanding that we may be unable to provide you with some of your desired services.
""";

  final String _termsText = """
**Terms of Service**

1. **Terms**
By accessing our app, Aura Health, you agree to be bound by these terms of service, all applicable laws and regulations, and agree that you are responsible for compliance with any applicable local laws.

2. **Use License**
Permission is granted to temporarily download one copy of the materials (information or software) on Aura Health's website for personal, non-commercial transitory viewing only.

3. **Disclaimer**
The materials on Aura Health's application are provided on an 'as is' basis. Aura Health makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.
""";
}