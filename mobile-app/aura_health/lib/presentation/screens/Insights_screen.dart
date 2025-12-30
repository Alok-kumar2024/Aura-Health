import 'package:aura_heallth/state/meal_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../model/meal_data.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMeals = ref.watch(allMealsNotifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Health Insights",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: asyncMeals.when(
        data: (meals) {
          if (meals.isEmpty) return _buildEmptyState();
          return _buildDashboard(meals);
        },
        error: (e, s) => Center(child: Text("Error loading insights: $e")),
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF1E88E5)),
              SizedBox(height: 16),
              Text("Generating health report...", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(List<MealData> meals) {
    // --- 1. METRICS CALCULATION ---
    final int totalScans = meals.length;
    final int safeMeals = meals.where((m) => m.status == 'safe').length;
    final int riskAlerts = meals.where((m) => m.status != 'safe').length;

    // Calculate percentage of meals with zero interactions
    final double safetyConsistency = totalScans == 0 ? 0 : (safeMeals / totalScans) * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HERO CONSISTENCY CARD
          _buildConsistencyCard(safetyConsistency, totalScans, riskAlerts),

          const SizedBox(height: 32),

          // 2. DAILY INTERACTION VOLUME CHART
          const Text("Daily Interaction Volume", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("Number of risks detected per scan", style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),
          _buildWeeklyChart(meals),

          const SizedBox(height: 32),

          // 3. STATUS DISTRIBUTION BARS
          const Text("Safety Distribution", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildInteractionStats(meals),

          const SizedBox(height: 32),

          // 4. FREQUENT TRIGGERS
          const Text("Frequent Triggers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("Foods that caused the most alerts", style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),
          _buildRiskyFoodsList(meals),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildConsistencyCard(double percent, int total, int alerts) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1E88E5).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          const Text("Safe Meal Consistency", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                percent.toStringAsFixed(0),
                style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold),
              ),
              const Text("%", style: TextStyle(color: Colors.white70, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildMiniStat("Total Logs", "$total", Icons.history)),
              Container(width: 1, height: 30, color: Colors.white24),
              Expanded(child: _buildMiniStat("Risks Found", "$alerts", Icons.warning_amber_rounded)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _buildWeeklyChart(List<MealData> meals) {
    // Show the last 7 logged meals chronologically
    final recentMeals = meals.take(7).toList().reversed.toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: recentMeals.map((m) {
          // Height maps to the specific number of interactions found
          final double barHeight = m.interactionCount == 0
              ? 10.0
              : (m.interactionCount * 45.0).clamp(30.0, 130.0);

          Color barColor;
          if (m.status == 'critical') {
            barColor = const Color(0xFFF44336);
          } else if (m.status == 'warning') {
            barColor = const Color(0xFFFF9800);
          } else {
            barColor = const Color(0xFF4CAF50);
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (m.interactionCount > 0)
                Text(
                  "${m.interactionCount}",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: barColor),
                ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: 16,
                height: barHeight,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: m.status == 'critical'
                      ? [BoxShadow(color: barColor.withOpacity(0.3), blurRadius: 6)]
                      : [],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                DateFormat('E').format(m.timestamp)[0],
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInteractionStats(List<MealData> meals) {
    final safe = meals.where((m) => m.status == 'safe').length;
    final warning = meals.where((m) => m.status == 'warning').length;
    final critical = meals.where((m) => m.status == 'critical').length;
    final total = meals.length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          _buildStatBar("Safe", safe, total, const Color(0xFF4CAF50)),
          const SizedBox(height: 20),
          _buildStatBar("Warning", warning, total, const Color(0xFFFF9800)),
          const SizedBox(height: 20),
          _buildStatBar("Critical", critical, total, const Color(0xFFF44336)),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, int count, int total, Color color) {
    final double percentage = total == 0 ? 0 : count / total;
    return Row(
      children: [
        SizedBox(width: 75, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.blueGrey))),
        Expanded(
          child: Container(
            height: 12,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6))),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text("${(percentage * 100).toInt()}%", style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildRiskyFoodsList(List<MealData> meals) {
    final unsafeMeals = meals.where((m) => m.status != 'safe').toList();
    final Map<String, int> foodCounts = {};

    for (var m in unsafeMeals) {
      foodCounts[m.mealName] = (foodCounts[m.mealName] ?? 0) + 1;
    }

    final sortedKeys = foodCounts.keys.toList()
      ..sort((a, b) => foodCounts[b]!.compareTo(foodCounts[a]!));

    if (sortedKeys.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: const Column(
          children: [
            Icon(Icons.verified_user_rounded, color: Colors.green, size: 48),
            SizedBox(height: 12),
            Text("No risky patterns detected!", style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return Column(
      children: sortedKeys.take(3).map((food) {
        final count = foodCounts[food];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.warning_rounded, color: Colors.red, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(food, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Found in $count unsafe logs", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_graph_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          const Text("No data to analyze yet", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const Text("Log your meals to see health insights.", style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}