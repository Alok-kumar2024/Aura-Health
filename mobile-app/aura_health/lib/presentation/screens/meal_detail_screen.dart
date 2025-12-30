import 'package:flutter/material.dart';
import '../../model/meal_data.dart';

class MealDetailScreen extends StatelessWidget {
  final MealData meal;

  const MealDetailScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final interactions = meal.rawData?.interactions ?? [];

    if (interactions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(meal.mealName), elevation: 0),
        body: const Center(
          child: Text("Interaction details are currently unavailable."),
        ),
      );
    }

    final detail = interactions.first;
    final isCritical = meal.status == 'critical';
    final isWarning = meal.status == 'warning';

    // Determine color based on safety status
    final statusColor = isCritical
        ? const Color(0xFFD32F2F)
        : (isWarning ? const Color(0xFFF57C00) : const Color(0xFF388E3C));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          meal.mealName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: statusColor,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SAFETY HEADER ---
            _buildSafetyHeader(meal.status, statusColor),
            const SizedBox(height: 24),

            // --- DRUG & FOOD INFO ---
            const Text(
              "Comparison",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              title: "Medication vs. Food",
              child: Row(
                children: [
                  _buildTag(
                    meal.rawData?.drug ?? "Unknown",
                    Colors.blue.shade700,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.compare_arrows, color: Colors.grey),
                  ),
                  _buildTag(meal.mealName, Colors.orange.shade700),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- AI INSIGHT SECTION ---
            const Text(
              "AI Insight",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              title: "Explanation",
              content: detail.aiExplanation,
              icon: Icons.auto_awesome,
              iconColor: Colors.deepPurple,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: "Reasoning",
              content: detail.reason,
              icon: Icons.info_outline,
              iconColor: Colors.blue,
            ),

            // --- ALTERNATIVES (Only show if not safe) ---
            if (isCritical || isWarning) ...[
              const SizedBox(height: 24),
              const Text(
                "Recommendations",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                title: "Suggested Alternatives",
                content: detail.alternatives,
                icon: Icons.lightbulb_outline,
                iconColor: Colors.green,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyHeader(String status, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            status == 'critical'
                ? Icons.warning_rounded
                : Icons.check_circle_rounded,
            color: color,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            status == 'critical'
                ? "Avoid this combination"
                : "This combination is likely safe",
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    String? content,
    Widget? child,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) Icon(icon, color: iconColor, size: 20),
              if (icon != null) const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child ??
              Text(
                content ?? "No information provided.",
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
