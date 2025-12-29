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
        error: (e, s) => Center(child: Text("Error: $e")),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildDashboard(List<MealData> meals) {
    // --- 1. CALCULATE METRICS ---
    final int totalScans = meals.length;
    final int interactionsAvoided = meals.where((m) => m.status != 'safe').length;

    double avgScore = 0;
    // if (meals.isNotEmpty) {
    //   avgScore = meals.fold(0, (sum, item) => sum + item.safetyScore) / totalScans;
    // }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HERO SCORE CARD
          _buildHeroScoreCard(avgScore, totalScans, interactionsAvoided),

          const SizedBox(height: 24),

          // 2. WEEKLY TREND CHART (Custom Widget)
          const Text("Weekly Safety Trend", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildWeeklyChart(meals),

          const SizedBox(height: 24),

          // 3. INTERACTION BREAKDOWN
          const Text("Interaction Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildInteractionStats(meals),

          const SizedBox(height: 24),

          // 4. TOP RISKY FOODS
          const Text("Frequent Triggers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("Foods that caused the most alerts", style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 12),
          _buildRiskyFoodsList(meals),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildHeroScoreCard(double score, int total, int avoided) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1E88E5).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          const Text("Average Safety Score", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            score.toStringAsFixed(0),
            style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold, height: 1),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildMiniStat("Total Scans", "$total", Icons.qr_code_scanner)),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(child: _buildMiniStat("Risks Found", "$avoided", Icons.warning_amber_rounded)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildWeeklyChart(List<MealData> meals) {
    // Simple logic to mock "Last 7 Days" data from the list
    // In a real app, you'd group 'meals' by day.
    // Here we just take the last 7 meals as a proxy for simplicity.
    final recentMeals = meals.take(7).toList().reversed.toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: recentMeals.map((m) {
          // Height based on score (0 to 100 map to 0 to 120px height)
          final double barHeight = (45 / 100) * 120;
          Color barColor = 75 >= 90 ? const Color(0xFF4CAF50) : (100 >= 70 ? const Color(0xFFFF9800) : const Color(0xFFF44336));

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 16,
                height: barHeight,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('E').format(m.timestamp)[0], // First letter of Day
                style: const TextStyle(fontSize: 12, color: Colors.grey),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildStatBar("Safe", safe, total, const Color(0xFF4CAF50)),
          const SizedBox(height: 16),
          _buildStatBar("Warning", warning, total, const Color(0xFFFF9800)),
          const SizedBox(height: 16),
          _buildStatBar("Critical", critical, total, const Color(0xFFF44336)),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, int count, int total, Color color) {
    final double percentage = total == 0 ? 0 : count / total;
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          "${(percentage * 100).toInt()}%",
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildRiskyFoodsList(List<MealData> meals) {
    // Logic: Filter unsafe meals -> Map to Names -> Count occurrences
    final unsafeMeals = meals.where((m) => m.status != 'safe').toList();

    // Map food names to frequency
    final Map<String, int> foodCounts = {};
    for (var m in unsafeMeals) {
      foodCounts[m.mealName] = (foodCounts[m.mealName] ?? 0) + 1;
    }

    // Sort by most frequent
    final sortedKeys = foodCounts.keys.toList()
      ..sort((a, b) => foodCounts[b]!.compareTo(foodCounts[a]!));

    if (sortedKeys.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Column(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 40),
            SizedBox(height: 8),
            Text("No risky foods detected yet!", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      children: sortedKeys.take(3).map((food) {
        final count = foodCounts[food];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.restaurant_menu, color: Colors.red, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(food, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Triggered $count alerts", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insights, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text("No data to analyze yet", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}