import 'package:aura_heallth/presentation/screens/Insights_screen.dart';
import 'package:aura_heallth/presentation/screens/add_meal_screen.dart';
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
        floatingActionButton: currentNav == BottomNavigator.HOME
            ? FloatingActionButton.extended(
                onPressed: () => _showVoiceInput(context),
                backgroundColor: const Color(0xFF1E88E5),
                elevation: 6,
                icon: const Icon(Icons.mic_rounded, color: Colors.white),
                label: const Text(
                  "Ask AI",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: switch (currentNav) {
              BottomNavigator.HOME => const HomeContent(key: ValueKey('Home')),
              BottomNavigator.HISTORY => MealHistoryScreen(
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
      builder: (ctx) => VoiceSheet(
        onResult: (String recognizedText) {
          Navigator.pop(ctx);
          showDialog(
            context: context,
            builder: (context) => AddMealScreen(initialText: recognizedText),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(bottomProvider);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
    final isSelected = isActive == ref.watch(bottomProvider);
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
                  fontWeight: FontWeight.bold,
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
    final medsCount = ref.watch(medicationProvider).length;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: HomeHeader()),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildStatusBanner(medsCount),
              const SizedBox(height: 32),

              // PRIMARY ACTION CARD
              const Text(
                "Meal Analysis",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildHeroActionCard(context),

              const SizedBox(height: 32),
              const ActiveMedicationSection(),
              const SizedBox(height: 120),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBanner(int medCount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Safe Interactions",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Aura is currently monitoring $medCount active medications for potential risks.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.shield_rounded, color: Colors.white, size: 44),
        ],
      ),
    );
  }

  Widget _buildHeroActionCard(BuildContext context) {
    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (context) => const AddMealScreen(),
      ),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE3F2FD), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                color: Color(0xFF1E88E5),
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Analyze Meal",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Check food-drug interactions manually",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
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
                  "Hi, ${profile.name} 👋",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "How are you feeling today?",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // IconButton(
          //   onPressed: () {}, // Future: Notifications
          //   icon: Icon(
          //     Icons.notifications_none_rounded,
          //     color: Colors.grey.shade400,
          //   ),
          // ),
        ],
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
              "Your Medication Vault",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w900,
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
                "Manage",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E88E5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (medications.isEmpty)
          _buildEmptyMeds()
        else
          ...medications
              .take(3)
              .map(
                (med) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MedicationCard(
                    name: med.name,
                    dose: "${med.dosage} • ${med.timing}",
                    category: med.schedule,
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildEmptyMeds() {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(
            Icons.medical_information_outlined,
            color: Colors.grey.shade300,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            "Vault is empty",
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Add meds to check meal safety",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
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
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dose,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
