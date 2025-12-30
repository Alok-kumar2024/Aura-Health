import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/meal_data.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final filterProvider = StateProvider<String>((ref) => 'all');

class MealNotifier extends AsyncNotifier<List<MealData>> {
  @override
  FutureOr<List<MealData>> build() => _fetchMealsFromApi();

  Future<List<MealData>> _fetchMealsFromApi() async {
    // 1. Get Real Authenticated UID
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return []; // No user, no history

    final uid = user.uid;
    // 2. Target the specific /history endpoint
    final url = Uri.parse('https://aura-health-rmow.onrender.com/history?uid=$uid');

    debugPrint("📥 [FETCH HISTORY] Requesting: $url");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> dataList = body['data'] ?? [];

        List<MealData> allMeals = [];
        for (var entry in dataList) {
          final List<dynamic> interactions = entry['interactions'] ?? [];
          for (var json in interactions) {
            allMeals.add(MealData.fromInteraction(InteractionResponse.fromJson(json)));
          }
        }
        debugPrint("✅ [FETCH HISTORY] Loaded ${allMeals.length} records");
        return allMeals;
      }
      return [];
    } catch (e) {
      debugPrint("⚠️ [FETCH HISTORY] Error: $e");
      return [];
    }
  }

  void addMeal(InteractionResponse interaction) {
    final newMeal = MealData.fromInteraction(interaction);
    state = AsyncData([newMeal, ...(state.value ?? [])]);
  }
}

final allMealsNotifier = AsyncNotifierProvider<MealNotifier, List<MealData>>(MealNotifier.new);

final displayedMealsProvider = Provider<AsyncValue<List<MealData>>>((ref) {
  final mealsAsync = ref.watch(allMealsNotifier);
  final filter = ref.watch(filterProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return mealsAsync.whenData((meals) {
    return meals.where((meal) {
      final matchesCategory = filter == 'all' || meal.status == filter;
      final matchesSearch = query.isEmpty || meal.mealName.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  });
});