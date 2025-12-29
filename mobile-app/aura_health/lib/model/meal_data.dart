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
    return InteractionResponse(
      drug: json['drug'] ?? 'Unknown Drug',
      food: json['food'] ?? 'Unknown Food',
      interactions: (json['interactions'] as List?)
          ?.map((i) => InteractionDetail.fromJson(i))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'drug': drug,
    'food': food,
    'interactions': interactions.map((i) => i.toJson()).toList(),
  };
}

class InteractionDetail {
  final String relation; // "NEGATIVE_INTERACTION", etc.
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

// --- 2. UI MODEL (What the History Screen displays) ---
class MealData {
  final String id;
  final String mealName;      // Will hold the 'Food' name
  final DateTime timestamp;   // Generated locally
  // final int safetyScore;      // Calculated based on interaction
  final String status;        // 'safe', 'warning', 'critical'
  final List<String> ingredients; // Will hold [Food, Drug]
  final int interactionCount;

  // Store the raw backend response in case we need details screen later
  final InteractionResponse? rawData;

  MealData({
    required this.id,
    required this.mealName,
    required this.timestamp,
    // required this.safetyScore,
    required this.status,
    required this.ingredients,
    required this.interactionCount,
    this.rawData,
  });

  // --- THE BRIDGE: Converts API Data to UI Data ---
  factory MealData.fromInteraction(InteractionResponse response) {

    final hasNegative = response.interactions.any((i) =>
    i.relation == "NEGATIVE_INTERACTION");

    final hasWarning = response.interactions.any((i) =>
    i.relation != "NEGATIVE_INTERACTION" &&
        i.relation != "SAFE" &&
        i.relation != "POSITIVE_INTERACTION"
    );

    final count = response.interactions.where((i){
      return i.relation != "SAFE" &&
          i.relation != "POSITIVE_INTERACTION";
    }).length;

    // 3. SET STATUS
    String status = 'safe'; // Default (Green)


    if (hasNegative) {
      status = 'critical'; // Red
    } else if (hasWarning) {
      status = 'warning';  // Orange
    }

    return MealData(
      id: const Uuid().v4(), // Generate random ID
      mealName: response.food, // The main title is the Food
      timestamp: DateTime.now(), // Use current time
      // safetyScore: score,
      status: status,
      ingredients: [response.food, response.drug], // Display tags
      interactionCount: count,
      rawData: response,
    );
  }
}