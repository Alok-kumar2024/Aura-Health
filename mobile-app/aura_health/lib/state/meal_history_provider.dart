import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/meal_data.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final filterProvider = StateProvider<String>((ref) => 'all');

class MealNotifier extends AsyncNotifier<List<MealData>> {

  @override
  FutureOr<List<MealData>> build() {
    return _fetchMealsFromApi();
  }

  Future<List<MealData>> _fetchMealsFromApi() async {
    // Replace with your actual Link
    final url = Uri.parse('YOUR_API_LINK_HERE');

    try {
      // 1. Fetch Data
      // final response = await http.get(url);

      // MOCKING THE RESPONSE FOR NOW (To match your JSON structure)
      await Future.delayed(const Duration(seconds: 1)); // Simulate Network
      final responseStatusCode = 200;

      // This mimics an API returning a LIST of your JSON objects
      final String mockBody = jsonEncode([
        {
          "drug": "Lepirudin",
          "food": "garlic",
          "interactions": [
            {
              "relation": "NEGATIVE_INTERACTION",
              "drug": "Lepirudin",
              "food": "garlic",
              "reason": "Garlic has antiplatelet and anticoagulant effects...",
              "alternatives": "Use onion...",
              "ai_explanation": "Limit garlic..."
            }
          ]
        },
        {
          "drug": "Paracetamol",
          "food": "Banana",
          "interactions": []
        }
      ]);

      if (responseStatusCode == 200) {
        final List<dynamic> data = jsonDecode(mockBody);

        // 2. Convert: JSON -> InteractionResponse -> MealData
        // This is where the magic happens
        return data.map((json) {
          final interaction = InteractionResponse.fromJson(json);
          return MealData.fromInteraction(interaction);
        }).toList();

      } else {
        throw Exception('Failed to load meals');
      }
    } catch (e) {
      print("Error fetching meals: $e");
      return [];
    }
  }

  // Add a meal (e.g., after taking a photo)
  Future<void> addMeal(InteractionResponse interaction) async {
    final previousState = state.value ?? [];

    // Convert to UI model immediately
    final newMeal = MealData.fromInteraction(interaction);

    // Update UI Optimistically
    state = AsyncData([newMeal, ...previousState]);

    try {
      // Send to Backend
      /*
      final response = await http.post(
          Uri.parse("YOUR_POST_LINK"),
          headers: {"Content-Type": "application/json"},
          body: json.encode(interaction.toJson())
      );
      */
    } catch (e) {
      // Revert if failed
      state = AsyncData(previousState);
    }
  }
}

final allMealsNotifier = AsyncNotifierProvider<MealNotifier, List<MealData>>(
      () => MealNotifier(),
);

// Filter Logic
final displayedMealsProvider = Provider<AsyncValue<List<MealData>>>((ref) {
  final mealsAsync = ref.watch(allMealsNotifier);
  final filter = ref.watch(filterProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return mealsAsync.whenData((meals) {
    return meals.where((meal) {
      final matchesCategory = filter == 'all' || meal.status == filter;
      final matchesSearch = query.isEmpty ||
          meal.mealName.toLowerCase().contains(query) ||
          meal.ingredients.any((i) => i.toLowerCase().contains(query));

      return matchesCategory && matchesSearch;
    }).toList();
  });
});