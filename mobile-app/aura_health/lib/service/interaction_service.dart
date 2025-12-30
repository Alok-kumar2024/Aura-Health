import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/meal_data.dart';

class InteractionService {
  final String _baseUrl = "https://aura-health-rmow.onrender.com";

  Future<List<InteractionResponse>> getFoodInteractions({
    required String uid,
    required List<String> drugs,
    required String food,
  }) async {
    final url = Uri.parse("$_baseUrl/getInteractions");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "uid": uid,
          "drug": drugs.join(", "),
          "food": food,
        }),
      ).timeout(const Duration(seconds: 30));

      debugPrint("📡 [API RESPONSE] Status: ${response.statusCode}");
      debugPrint("📄 [API RESPONSE] Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body = jsonDecode(response.body);

        // FIX: Access 'interactions' directly from the root body
        final List<dynamic> interactionsData = body['interactions'] ?? [];

        debugPrint("🔍 [SERVICE] Parsed ${interactionsData.length} interaction(s)");

        return interactionsData.map((item) => InteractionResponse.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ [SERVICE] Error: $e");
      throw Exception("Failed to connect: $e");
    }
  }

// Inside your InteractionService class
  // Inside your InteractionService class
  Future<bool> deleteBackendHistory(String uid) async {
    try {
      final url = Uri.parse("https://aura-health-rmow.onrender.com/clearHistory?uid=$uid");
      debugPrint("📡 [API REQUEST] DELETE History for UID: $uid");

      final response = await http.delete(url).timeout(const Duration(seconds: 15));

      debugPrint("📡 [API RESPONSE] Status: ${response.statusCode}");
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("❌ [API ERROR]: $e");
      return false;
    }
  }

}