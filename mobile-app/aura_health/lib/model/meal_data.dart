import 'package:uuid/uuid.dart';

import 'package:uuid/uuid.dart';

class InteractionResponse {
  final String drug;
  final String food;
  final List<InteractionDetail> interactions;

  InteractionResponse({
    required this.drug,
    required this.food,
    required this.interactions,
  });

  factory InteractionResponse.fromJson(Map<String, dynamic> json) {
    // FIX: Navigating the nested 'result' -> 'interactions' path from your log
    List<InteractionDetail> extractedInteractions = [];

    if (json['result'] != null && json['result']['interactions'] != null) {
      extractedInteractions = (json['result']['interactions'] as List)
          .map((i) => InteractionDetail.fromJson(i))
          .toList();
    }

    return InteractionResponse(
      drug: json['drug'] ?? 'Unknown Drug',
      food: json['food'] ?? 'Unknown Food',
      interactions: extractedInteractions,
    );
  }

  Map<String, dynamic> toJson() => {
    'drug': drug,
    'food': food,
    'interactions': interactions.map((i) => i.toJson()).toList(),
  };
}

class InteractionDetail {
  final String relation;
  final String reason;
  final String alternatives;
  final String aiExplanation;

  InteractionDetail({
    required this.relation,
    required this.reason,
    required this.alternatives,
    required this.aiExplanation,
  });

  factory InteractionDetail.fromJson(Map<String, dynamic> json) {
    return InteractionDetail(
      relation: json['relation'] ?? 'UNKNOWN',
      reason: json['reason'] ?? 'No reason provided.',
      alternatives: json['alternatives'] ?? 'None.',
      aiExplanation: json['ai_explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'relation': relation,
    'reason': reason,
    'alternatives': alternatives,
    'ai_explanation': aiExplanation,
  };
}

class MealData {
  final String id;
  final String mealName;
  final DateTime timestamp;
  final String status;
  final List<String> ingredients;
  final int interactionCount;
  final InteractionResponse? rawData;

  MealData({
    required this.id,
    required this.mealName,
    required this.timestamp,
    required this.status,
    required this.ingredients,
    required this.interactionCount,
    this.rawData,
  });

  factory MealData.fromInteraction(InteractionResponse response) {
    // Handle empty list case to prevent crashes
    if (response.interactions.isEmpty) {
      return MealData(
        id: const Uuid().v4(),
        mealName: response.food,
        timestamp: DateTime.now(),
        status: 'safe',
        ingredients: [response.food, response.drug],
        interactionCount: 0,
        rawData: response,
      );
    }

    final hasNegative = response.interactions.any((i) => i.relation == "NEGATIVE_INTERACTION");
    final hasWarning = response.interactions.any((i) =>
    i.relation != "NEGATIVE_INTERACTION" &&
        i.relation != "SAFE" &&
        i.relation != "POSITIVE_INTERACTION");

    final count = response.interactions.where((i) =>
    i.relation != "SAFE" && i.relation != "POSITIVE_INTERACTION").length;

    String status = 'safe';
    if (hasNegative) {
      status = 'critical';
    } else if (hasWarning) {
      status = 'warning';
    }

    return MealData(
      id: const Uuid().v4(),
      mealName: response.food,
      timestamp: DateTime.now(),
      status: status,
      ingredients: [response.food, response.drug],
      interactionCount: count,
      rawData: response,
    );
  }
}