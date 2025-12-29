import 'package:aura_heallth/presentation/screens/Insights_screen.dart';
import 'package:aura_heallth/presentation/screens/camera_screen.dart';
import 'package:aura_heallth/presentation/screens/meal_history_screen.dart';
import 'package:aura_heallth/presentation/screens/profile_screen.dart';
import 'package:aura_heallth/state/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        backgroundColor: const Color(0xFFF8F9FA), // Cleaner off-white background

        // --- VOICE INPUT BUTTON ---
        floatingActionButton: currentNav == BottomNavigator.HOME
            ? FloatingActionButton(
          onPressed: () => _showVoiceInput(context),
          backgroundColor: const Color(0xFF1E88E5), // AppColors.primaryBlue
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.mic_rounded, color: Colors.white, size: 28),
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
                  scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: switch (currentNav) {
              BottomNavigator.HOME => const HomeContent(key: ValueKey('Home')),
              BottomNavigator.HISTORY => const MealHistoryScreen(key: ValueKey('History')),
              BottomNavigator.INSIGHT => const InsightsScreen(key: ValueKey('Insights'),),
              BottomNavigator.PROFILE => const ProfileScreen(key: ValueKey('Profile'),),
            },
          ),
        ),
        bottomNavigationBar: _buildBottomNav(context, ref),
      ),
    );
  }

  // --- VOICE INPUT MODAL SHEET ---
  void _showVoiceInput(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Listening...",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Try saying: 'I had 2 eggs and toast'",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
              ),
              const SizedBox(height: 40),
              // Fake Audio Waveform Animation Placeholder
              Container(
                height: 60,
                width: double.infinity,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(5, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: 8,
                      height: 20 + (index % 3) * 15.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 40),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey.shade100),
                    child: const Icon(Icons.close, color: Colors.grey)),
                iconSize: 24,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNav(BuildContext context, WidgetRef ref) {
    void changeScreen(BottomNavigator bottomNav) {
      final nav = ref.watch(bottomProvider);
      if (nav == bottomNav) return;
      ref.read(bottomProvider.notifier).goToNextScreen(bottomNav);
    }

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
          child: Consumer(
            builder: (context, ref, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                    ref: ref,
                    isActive: BottomNavigator.HOME,
                    icons: Icons.home_rounded,
                    label: "Home",
                    onTap: () => changeScreen(BottomNavigator.HOME),
                  ),
                  _buildNavItem(
                    ref: ref,
                    isActive: BottomNavigator.HISTORY,
                    icons: Icons.history_rounded,
                    label: "History",
                    onTap: () => changeScreen(BottomNavigator.HISTORY),
                  ),
                  _buildNavItem(
                    ref: ref,
                    isActive: BottomNavigator.INSIGHT,
                    icons: Icons.bar_chart_rounded,
                    label: "Insights",
                    onTap: () => changeScreen(BottomNavigator.INSIGHT),
                  ),
                  _buildNavItem(
                    ref: ref,
                    isActive: BottomNavigator.PROFILE,
                    icons: Icons.person_rounded,
                    label: "Profile",
                    onTap: () => changeScreen(BottomNavigator.PROFILE),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required WidgetRef ref,
    required IconData icons,
    required String label,
    required BottomNavigator isActive,
    required VoidCallback onTap,
  }) {
    final bottomWatch = ref.watch(bottomProvider);
    final isSelected = isActive == bottomWatch;
    // Primary Color Fallback
    final primaryColor = const Color(0xFF1E88E5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
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
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SUB-WIDGETS
// ---------------------------------------------------------------------------

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: HomeHeader()),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const HealthScore(),
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
                      bgColor: const Color(0xFF1E88E5),
                      title: "Scan Meal",
                      subtitle: "Check Safety",
                      textColor: Colors.white,
                      icon: Icons.qr_code_scanner_rounded,
                      iconColor: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CameraScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ActionCard(
                      bgColor: Colors.white,
                      title: "Log Food",
                      subtitle: "Manual Entry",
                      textColor: Colors.black87,
                      borderColor: Colors.grey.shade200,
                      borderWidth: 1,
                      icon: Icons.edit_note_rounded,
                      iconColor: const Color(0xFF1E88E5),
                      onTap: () => print("Log Food Tapped"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const ActiveMedicationSection(),
              const SizedBox(height: 80), // Padding for FAB
            ]),
          ),
        ),
      ],
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: NetworkImage("https://i.pravatar.cc/150?u=sarah"),
                fit: BoxFit.cover,
              ),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            // child: const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hello, Sarah 👋",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
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
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
              color: Colors.white,
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded),
              color: Colors.black87,
              iconSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class HealthScore extends StatelessWidget {
  const HealthScore({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.3),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Safety Score",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "92",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "No interactions detected today",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
  final Color? borderColor;
  final Color textColor;
  final String title;
  final String subtitle;
  final double borderWidth;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.borderColor,
    required this.textColor,
    required this.title,
    required this.subtitle,
    this.borderWidth = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? Colors.transparent,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor == Colors.white
                        ? Colors.white.withOpacity(0.2)
                        : iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ActiveMedicationSection extends StatelessWidget {
  const ActiveMedicationSection({super.key});

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {},
              child: const Text("See All"),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (c, i) => const SizedBox(height: 12),
          itemBuilder: (ctx, idx) {
            // Mock Data Logic
            if (idx == 0) {
              return const MedicationCard(
                name: "Amoxicillin",
                dose: "500mg • After Meal",
                time: "08:00 AM",
                isTaken: true,
              );
            } else if (idx == 1) {
              return const MedicationCard(
                name: "Vitamin D",
                dose: "1 Tablet",
                time: "01:00 PM",
                isTaken: false,
              );
            }
            return const MedicationCard(
              name: "Cetirizine",
              dose: "10mg • Before Bed",
              time: "09:00 PM",
              isTaken: false,
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
  final String time;
  final bool isTaken;

  const MedicationCard({
    super.key,
    required this.name,
    required this.dose,
    required this.time,
    required this.isTaken,
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
            color: Colors.grey.withOpacity(0.05),
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
              color: const Color(0xFFF0F7FF), // Light blue tint
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.medication_liquid_rounded,
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
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dose,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              if (isTaken)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check, size: 12, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        "Taken",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Icon(
                  Icons.circle_outlined,
                  color: Colors.grey.shade300,
                  size: 20,
                ),
            ],
          )
        ],
      ),
    );
  }
}