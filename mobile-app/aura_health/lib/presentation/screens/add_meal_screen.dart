import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/meal_data.dart';
import '../../service/interaction_service.dart';
import '../../state/meal_history_provider.dart';
import '../../state/medication_provider.dart';
import 'meal_detail_screen.dart';

class AddMealScreen extends ConsumerStatefulWidget {
  final String? initialText;

  const AddMealScreen({super.key, this.initialText});

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  late TextEditingController _foodController;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _foodController = TextEditingController(text: widget.initialText ?? "");
  }

  @override
  void dispose() {
    _foodController.dispose();
    super.dispose();
  }

  // --- PREMIUM SNACKBAR ---
  void _showPremiumStatus(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.auto_awesome_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // --- FANCY AI LOADING OVERLAY ---
  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 80,
                      width: 80,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Color(0xFF1E88E5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "AI Interaction Scan",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Analyzing your medications against this meal...",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleAnalyze() async {
    final foodText = _foodController.text.trim();
    if (foodText.isEmpty) return;

    debugPrint("📝 [UI] User Input: $foodText");
    // Navigator.pop(context);
    _showProcessingDialog();
    HapticFeedback.mediumImpact();

    try {
      // 1. Data Prep
      final meds = ref.read(medicationProvider).map((m) => m.name).toList();
      final uid = FirebaseAuth.instance.currentUser?.uid ?? "111";

      debugPrint("💊 [UI] Meds to check: $meds");

      // 2. API Call
      final service = InteractionService();
      final List<InteractionResponse> results = await service
          .getFoodInteractions(uid: uid, drugs: meds, food: foodText);

      if (mounted) {
        // 3. POP sequence: Close Loader, then close AddMeal dialog
        Navigator.of(context, rootNavigator: true).pop(); // Close Loader
        Navigator.of(context).pop(); // Close AddMeal Dialog

        if (results.isNotEmpty) {
          debugPrint("✅ [UI] Interactions found: ${results.length}");

          // Update History Provider
          for (var res in results) {
            ref.read(allMealsNotifier.notifier).addMeal(res);
          }

          // Navigate to immediate detail view
          final mealData = MealData.fromInteraction(results.first);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MealDetailScreen(meal: mealData)),
          );
        } else {
          _showPremiumStatus("No interactions detected. Enjoy your meal!");
        }
      }
    } catch (e) {
      debugPrint("💥 [UI] Error: $e");
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      _showPremiumStatus("Analysis failed. Please try again.", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.restaurant_menu_rounded, color: Color(0xFF1E88E5), size: 20),
          ),
          const SizedBox(width: 12),
          const Text("Log Meal", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Enter your meal to check for safety and potential drug interactions.",
            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _foodController,
            maxLines: 4,
            autofocus: true,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            decoration: InputDecoration(
              hintText: "e.g. Garlic bread and a glass of milk",
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _handleAnalyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Analyze Food", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }
}