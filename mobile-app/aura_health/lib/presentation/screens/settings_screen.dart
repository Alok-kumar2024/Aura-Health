import 'package:aura_heallth/presentation/screens/personal_details_screen.dart';
import 'package:aura_heallth/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../service/interaction_service.dart';
import '../../service/local_storage_service.dart';
import '../../state/meal_history_provider.dart';
import '../../state/profile_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isResettingPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Account & Security"),
            _buildActionTile(
              icon: Icons.person_outline_rounded,
              title: "Edit Profile",
              subtitle: "Vitals, Identity & Avatar",
              onTap: () {
                final currentProfile = ref.read(profileProvider);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PersonalDetailsScreen(existingProfile: currentProfile)),
                );
              },
            ),
            _buildActionTile(
              icon: Icons.lock_reset_rounded,
              title: "Change Password",
              subtitle: "Reset via secure email link",
              onTap: () => _showPasswordResetDialog(context),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader("Data Management"),
            _buildActionTile(
              icon: Icons.auto_delete_outlined,
              title: "Clear Health Records",
              subtitle: "Wipe meal and medication history",
              onTap: () => _showClearDataDialog(context),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader("Help & Support"),
            _buildActionTile(
              icon: Icons.support_agent_rounded,
              title: "Help Center",
              subtitle: "FAQs & Direct Support",
              onTap: () => _showHelpCenter(context),
            ),
            _buildActionTile(
              icon: Icons.shield_outlined,
              title: "Privacy Policy",
              onTap: () => _showLegalSheet(context, "Privacy Policy", _privacyPolicyContent()),
            ),
            _buildActionTile(
              icon: Icons.gavel_rounded,
              title: "Terms of Service",
              onTap: () => _showLegalSheet(context, "Terms of Service", _termsContent()),
            ),

            // const SizedBox(height: 32),
            // _buildSectionHeader("Danger Zone"),
            // _buildActionTile(
            //   icon: Icons.no_accounts_rounded,
            //   title: "Delete Account",
            //   subtitle: "Permanently erase all data",
            //   isDestructive: true,
            //   onTap: () => _showDeleteAccountDialog(context),
            // ),

            const SizedBox(height: 40),
            _buildLogoutButton(),
            const SizedBox(height: 40),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // --- MODERN DIALOGS ---

  void _showPasswordResetDialog(BuildContext context) {
    final email = ref.read(authProvider).value?.email ?? "your email";

    showDialog(
      context: context,
      barrierDismissible: !_isResettingPassword,
      builder: (ctx) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF1E88E5).withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.alternate_email_rounded, color: Color(0xFF1E88E5), size: 36),
                  ),
                  const SizedBox(height: 24),
                  const Text("Reset Password", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                  const SizedBox(height: 12),
                  Text(
                    "We'll send a secure link to $email. Please follow the link to set a new password.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.6),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isResettingPassword ? null : () => Navigator.pop(ctx),
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
                        onPressed: _isResettingPassword ? null : () async {
                          setDialogState(() => _isResettingPassword = true);
                          try {
                            await ref.read(authProvider.notifier).resetPassword();
                            if (mounted) {
                              Navigator.pop(ctx);
                              _showSuccessSnackBar("Reset link sent! Check your inbox.");
                            }
                          } finally {
                            if (mounted) setDialogState(() => _isResettingPassword = false);
                          }
                        },
                        child: _isResettingPassword
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Send Link", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
      ),
    );
  }

  // --- GENERIC DIALOG HELPER FOR OTHER ACTIONS ---
  void _showAppDialog(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    required String actionText,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 36),
            ),
            const SizedBox(height: 24),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
            const SizedBox(height: 12),
            Text(content, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.6)),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDestructive ? Colors.red : const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    onConfirm();
                  },
                  child: Text(actionText, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    bool _isClearing = false; // Local state for the loader

    showDialog(
      context: context,
      barrierDismissible: !_isClearing, // Prevent closing while deleting
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.history_toggle_off_rounded, color: Colors.orange, size: 36),
                ),
                const SizedBox(height: 24),
                const Text("Clear Records?", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                const SizedBox(height: 12),
                Text(
                  "This will permanently wipe your history from our servers and this device. This cannot be undone.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.6),
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isClearing ? null : () => Navigator.pop(ctx),
                      child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _isClearing ? null : () async {
                        setDialogState(() => _isClearing = true);

                        final uid = ref.read(authProvider).value?.uid;
                        if (uid != null) {
                          // 1. Clear Backend
                          final success = await InteractionService().deleteBackendHistory(uid);

                          if (success) {
                            // 2. Clear Local Storage
                            await LocalStorageService().clearAll();
                            // 3. Refresh Providers
                            ref.refresh(allMealsNotifier);

                            if (mounted) {
                              Navigator.pop(ctx);
                              _showSuccessSnackBar("All health records have been wiped.");
                            }
                          } else {
                            if (mounted) {
                              setDialogState(() => _isClearing = false);
                              _showErrorSnackBar("Backend sync failed. Please try again.");
                            }
                          }
                        }
                      },
                      child: _isClearing
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : const Text("Wipe Data", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(20),
    ));
  }

  void _showDeleteAccountDialog(BuildContext context) {
    HapticFeedback.heavyImpact();
    _showAppDialog(
      context,
      icon: Icons.report_problem_rounded,
      iconColor: Colors.red,
      title: "Delete Account?",
      content: "This is irreversible. All health trends, medical records, and AI profiles will be permanently destroyed.",
      actionText: "Delete Forever",
      isDestructive: true,
      onConfirm: () async {
        await ref.read(authProvider.notifier).logout();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
        }
      },
    );
  }

  // --- BOTTOM SHEETS ---

  void _showHelpCenter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            const Text("Help Center", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text("Find answers or reach out to our support team.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            // _buildFaqItem("How does AI scan prescriptions?", "Aura Health uses Gemini 1.5 Flash to parse document text. For best results, use bright lighting and clear images."),
            _buildFaqItem("Is my data secure?", "Your medical data is stored locally and synced via encrypted Firebase channels. We never sell your personal info."),
            _buildFaqItem("Can I export my data?", "Currently, data is device-locked. We are working on a PDF export feature for future releases."),
            const SizedBox(height: 32),
            const Text("Contact Us", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 16),
            _buildContactTile(Icons.mail_rounded, "support@aurahealth.com", "Email Support"),
            // _buildContactTile(Icons.chat_bubble_rounded, "Live Chat", "Available 9 AM - 6 PM"),
          ],
        ),
      ),
    );
  }

  void _showLegalSheet(BuildContext context, String title, Widget content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          child: Column(
            children: [
              Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  children: [content],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI COMPONENT HELPERS ---

  Widget _buildFaqItem(String q, String a) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(q, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      children: [Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(a, style: const TextStyle(color: Colors.blueGrey, height: 1.5)))],
    );
  }

  Widget _buildContactTile(IconData icon, String title, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2E7D32)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () => _handleLogout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.red.shade100)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.power_settings_new_rounded, size: 22),
            SizedBox(width: 12),
            Text("Sign Out", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    _showAppDialog(
      context,
      icon: Icons.logout_rounded,
      iconColor: Colors.red,
      title: "Sign Out?",
      content: "You will be returned to the login screen. Your local health records will be kept safe.",
      actionText: "Sign Out",
      onConfirm: () async {
        await ref.read(authProvider.notifier).logout();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
        }
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade200, letterSpacing: 1.5)),
    );
  }

  Widget _buildActionTile({required IconData icon, required String title, String? subtitle, bool isDestructive = false, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))]),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: (isDestructive ? Colors.red : const Color(0xFF1E88E5)).withOpacity(0.08), shape: BoxShape.circle),
          child: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF1E88E5), size: 24),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isDestructive ? Colors.red : Colors.black87)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)) : null,
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      ),
    );
  }

  void _showSuccessSnackBar(String msg) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      backgroundColor: Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(20),
    ));
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          const Text("AURA HEALTH", style: TextStyle(color: Colors.black26, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 4),
          Text("v1.0.4 Stable Release", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        ],
      ),
    );
  }

  // --- LEGAL CONTENTS ---

  Widget _privacyPolicyContent() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("1. Data Security", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        SizedBox(height: 8),
        Text("Aura Health stores your medical logs and vitals locally on your device. Syncing is handled via industry-standard Firebase encryption. We never access your prescription images directly."),
        SizedBox(height: 24),
        Text("2. AI Privacy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        SizedBox(height: 8),
        Text("When you scan a document, the data is processed by Gemini AI. No images are stored on our servers after the text extraction is complete."),
        SizedBox(height: 24),
        Text("3. Your Rights", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        SizedBox(height: 8),
        Text("You have the right to request account deletion and clear all local caches at any time. Your data belongs to you."),
      ],
    );
  }

  Widget _termsContent() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("1. Disclaimer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        SizedBox(height: 8),
        Text("Aura Health is an AI assistant, not a licensed medical professional. Always consult a doctor before making medical decisions based on AI analysis."),
        SizedBox(height: 24),
        Text("2. Accuracy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        SizedBox(height: 8),
        Text("While we use state-of-the-art AI, prescription scanning and calorie counting are estimates. Users are responsible for verifying all logged data."),
        SizedBox(height: 24),
        Text("3. Usage", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        SizedBox(height: 8),
        Text("By using this app, you agree to provide truthful information to ensure the most accurate health tracking possible."),
      ],
    );
  }
}