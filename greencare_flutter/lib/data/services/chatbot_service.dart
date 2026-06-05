import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_config.dart';

class ChatbotService {
  static const String _chatUrl = '$backendBaseUrl/api/chat';
  static const String _plantCareUrl = '$backendBaseUrl/api/plant-care';

  Future<String> sendMessage(List<Map<String, String>> messages) async {
    try {
      final response = await http
          .post(
            Uri.parse(_chatUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'messages': messages}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] as String;
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ChatbotService error: $e');
      rethrow;
    }
  }

  Future<Map<String, String>> getPlantCare(String plantName) async {
    try {
      final response = await http
          .post(
            Uri.parse(_plantCareUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'plantName': plantName}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'watering': data['watering'] ?? 'Average',
          'sunlight': data['sunlight'] ?? 'part shade',
          'cycle': data['cycle'] ?? 'Perennial',
        };
      }
    } catch (e) {
      debugPrint('getPlantCare error: $e');
    }
    return {
      'watering': 'Average',
      'sunlight': 'part shade',
      'cycle': 'Perennial',
    };
  }

  Future<String?> getWikimediaImage(String scientificName) async {
    try {
      final encoded = Uri.encodeComponent(scientificName);
      final url = 'https://en.wikipedia.org/api/rest_v1/page/summary/$encoded';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['thumbnail']?['source'] as String?;
      }
    } catch (e) {
      debugPrint('Wikimedia error: $e');
    }
    return null;
  }

  Future<String?> translateToEnglish(String text) async {
    try {
      final response = await http
          .post(
            Uri.parse('$backendBaseUrl/api/translate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'text': text}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translation'] as String?;
      }
    } catch (e) {
      debugPrint('translateToEnglish error: $e');
    }
    return null;
  }
}
