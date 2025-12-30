import 'package:aura_heallth/presentation/screens/Insights_screen.dart';
import 'package:aura_heallth/presentation/screens/add_meal_screen.dart';
import 'package:aura_heallth/presentation/screens/camera_screen.dart';
import 'package:aura_heallth/presentation/screens/meal_history_screen.dart';
import 'package:aura_heallth/presentation/screens/profile_screen.dart';
import 'package:aura_heallth/presentation/screens/voice_sheet_screen.dart';
import 'package:aura_heallth/state/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/medication_provider.dart';
import '../../state/profile_provider.dart';
import '../widgets/user_avatar.dart';
import 'medicine_vault_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentNav = ref.watch(bottomProvider);

    return PopScope(
      canPop: currentNav == BottomNavigator.HOME,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        ref.read(bottomProvider.notifier).goToNextScreen(BottomNavigator.HOME);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),

        // --- VOICE INPUT BUTTON ---
        floatingActionButton: currentNav == BottomNavigator.HOME
            ? FloatingActionButton(
                onPressed: () => _showVoiceInput(context),
                backgroundColor: const Color(0xFF1E88E5),
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.mic_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

        // --- BODY CONTENT ---
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.98,
                    end: 1.0,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: switch (currentNav) {
              BottomNavigator.HOME => const HomeContent(key: ValueKey('Home')),
              BottomNavigator.HISTORY =>  MealHistoryScreen(
                key: ValueKey('History'),
              ),
              BottomNavigator.INSIGHT => const InsightsScreen(
                key: ValueKey('Insights'),
              ),
              BottomNavigator.PROFILE => const ProfileScreen(
                key: ValueKey('Profile'),
              ),
            },
          ),
        ),
        bottomNavigationBar: _buildBottomNav(context, ref),
      ),
    );
  }

  void _showVoiceInput(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return VoiceSheet(
          onResult: (String recognizedText) {
            Navigator.pop(ctx);
            showDialog(
              context: context,
              builder: (context) => AddMealScreen(initialText: recognizedText),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomNav(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(bottomProvider);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                ref,
                Icons.home_rounded,
                "Home",
                BottomNavigator.HOME,
              ),
              _buildNavItem(
                ref,
                Icons.history_rounded,
                "History",
                BottomNavigator.HISTORY,
              ),
              _buildNavItem(
                ref,
                Icons.bar_chart_rounded,
                "Insights",
                BottomNavigator.INSIGHT,
              ),
              _buildNavItem(
                ref,
                Icons.person_rounded,
                "Profile",
                BottomNavigator.PROFILE,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    WidgetRef ref,
    IconData icons,
    String label,
    BottomNavigator isActive,
  ) {
    final bottomWatch = ref.watch(bottomProvider);
    final isSelected = isActive == bottomWatch;
    const primaryColor = Color(0xFF1E88E5);

    return InkWell(
      onTap: () => ref.read(bottomProvider.notifier).goToNextScreen(isActive),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icons,
              color: isSelected ? primaryColor : Colors.grey.shade400,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meds = ref.watch(medicationProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: HomeHeader()),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildDailyOverviewBanner(meds.length),
              const SizedBox(height: 24),
              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ActionCard(
                      bgColor: const Color(0xFFE3F2FD),
                      title: "Snap Meal",
                      subtitle: "ML Analysis",
                      textColor: const Color(0xFF1E88E5),
                      icon: Icons.camera_enhance_rounded,
                      iconColor: const Color(0xFF1E88E5),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CameraScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ActionCard(
                      bgColor: const Color(0xFFF1F8E9),
                      title: "Log Food",
                      subtitle: "Manual Entry",
                      textColor: const Color(0xFF2E7D32),
                      icon: Icons.restaurant_rounded,
                      iconColor: const Color(0xFF2E7D32),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => const AddMealScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const ActiveMedicationSection(),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyOverviewBanner(int medCount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Health Today",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You have $medCount medications currently active in your vault.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
        ],
      ),
    );
  }
}

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Row(
        children: [
          UserAvatar(
            imagePath: profile.imagePath,
            name: profile.name,
            radius: 28,
            fontSize: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, ${profile.name} 👋",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "Tap the mic to log meals",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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

class ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color textColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.textColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActiveMedicationSection extends ConsumerWidget {
  const ActiveMedicationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Scheduled Meds",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MedicationVaultScreen(),
                ),
              ),
              child: const Text(
                "See All",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (medications.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: const Text(
              "No medications added yet.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: medications.length > 3 ? 3 : medications.length,
            separatorBuilder: (c, i) => const SizedBox(height: 12),
            itemBuilder: (ctx, idx) {
              final med = medications[idx];
              return MedicationCard(
                name: med.name,
                dose: "${med.dosage} • ${med.timing}",
                category: med.schedule,
              );
            },
          ),
      ],
    );
  }
}

class MedicationCard extends StatelessWidget {
  final String name;
  final String dose;
  final String category;

  const MedicationCard({
    super.key,
    required this.name,
    required this.dose,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.medical_services_outlined,
              color: Color(0xFF1E88E5),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  dose,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
