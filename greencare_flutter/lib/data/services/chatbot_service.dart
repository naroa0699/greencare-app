import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatbotService {
  // Para desarrollo local con emulador Android usa 10.0.2.2 en vez de localhost
  static const String _backendUrl = 'http://192.168.0.21:3000/api/chat';

  Future<String> sendMessage(List<Map<String, String>> messages) async {
    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'messages': messages}),
      ).timeout(const Duration(seconds: 30));

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
}