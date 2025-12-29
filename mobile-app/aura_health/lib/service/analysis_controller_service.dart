import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalysisControllerService extends AsyncNotifier<Map<String, dynamic>? >{
  @override
  FutureOr<Map<String, dynamic>?> build() {
    return null;
  }
  
  Future<void> analyzeImage (String imagePath) async{
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      var uri = Uri.parse("Will Paste the URI here...");
      var request = http.MultipartRequest('POST',uri);
      request.files.add(await http.MultipartFile.fromPath("file", imagePath));

    });
  }
  
}