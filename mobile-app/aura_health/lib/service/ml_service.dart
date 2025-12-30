import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mlServiceProvider = Provider((ref) => MLService());

class MLService {
  // Use the exact endpoint confirmed by your Swagger docs
  final String _apiUrl = "https://aura-health-5qqj.onrender.com/detect-drugs";

  Future<List<Map<String, dynamic>>> extractMeds(Uint8List bytes, String mimeType) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_apiUrl));

      // 1. Ensure the field name is "file" as required by the schema
      // 2. Explicitly set filename and MediaType for FastAPI binary string validation
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'prescription.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));

      // Render free tier can take time to wake up, so use a 60s timeout
      var streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> drugs = data['drugs_detected'] ?? [];

        return drugs.map((drugName) => {
          "name": drugName.toString(),
          "dosage": "Consult Doctor",
          "timing": "As prescribed",
          "schedule": "New Prescription"
        }).toList();
      } else {
        // Log the body to see validation error details if it fails again
        print("Backend Error: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("ML API Error: $e");
      return [];
    }
  }
}