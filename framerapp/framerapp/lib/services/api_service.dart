import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  // ── Plant disease prediction ──────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> predict({
    required dynamic imageFile, // XFile
    required String plant,
  }) async {
    final uri = Uri.parse(predictUrl);

    // Read image bytes and encode as base64 (works on both web and mobile)
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64Image, 'plant': plant}),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      // fallback if server wraps in a map
      if (decoded is Map && decoded['predictions'] is List) {
        return (decoded['predictions'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      return [];
    } else {
      throw Exception('Prediction failed: ${response.body}');
    }
  }

  // ── Deepseek chatbot ──────────────────────────────────────────────────────
  static Future<String> askDeepseek({
    required String plant,
    required List<Map<String, dynamic>> predictions,
    required String userQuestion,
    required List<Map<String, String>> conversation,
    String language = 'english',
    bool isInitialAnalysis = false,
  }) async {
    final uri = Uri.parse(deepseekUrl);

    final context = {
      'plant': plant,
      'plantDisplayName': plant,
      'predictions': predictions,
      'userQuestion': userQuestion,
      'conversation': conversation,
      'nearbyPlaces': [],
      'language': language,
      'isInitialAnalysis': isInitialAnalysis,
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt_data': jsonEncode(context)}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is String) return data;
      if (data is Map) {
        return data['response'] ?? data['answer'] ?? jsonEncode(data);
      }
      return data.toString();
    } else {
      throw Exception('Chatbot failed: ${response.body}');
    }
  }
}
