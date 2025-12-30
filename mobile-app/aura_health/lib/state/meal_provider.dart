import 'package:flutter_riverpod/flutter_riverpod.dart';

class Meal {
  final String id;
  final String name;
  final DateTime timestamp;
  final int calories;
  final bool isSafe;

  Meal({
    required this.id,
    required this.name,
    required this.timestamp,
    required this.calories,
    this.isSafe = true,
  });
}

class MealNotifier extends Notifier<List<Meal>> {
  @override
  List<Meal> build() => [];

  void addMeal(String name, int calories) {
    final newMeal = Meal(
      id: DateTime.now().toString(),
      name: name,
      timestamp: DateTime.now(),
      calories: calories,
    );
    state = [newMeal, ...state];
  }
}

final mealProvider = NotifierProvider<MealNotifier, List<Meal>>(MealNotifier.new);