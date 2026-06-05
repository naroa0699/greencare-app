import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// Mismo nivel de import que chatbot_service.dart (misma carpeta).
import '../../../core/constants/app_config.dart';
import '../../../core/constants/care_schedule.dart';

/// Obtiene el tiempo de la ubicacion de una planta a traves del backend
/// (que consulta Open-Meteo). Si algo falla devuelve null, y el calculo
/// de riego usa el intervalo base sin ajuste.
class WeatherService {
  Future<WeatherData?> getWeather(double lat, double lon) async {
    try {
      final response = await http
          .post(
            Uri.parse('$backendBaseUrl/api/weather'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'lat': lat, 'lon': lon}),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherData(
          maxTemp: (data['maxTemp'] as num).toDouble(),
          minTemp: (data['minTemp'] as num).toDouble(),
          humidity: (data['humidity'] as num).toDouble(),
          precipitationMm: (data['precipitationMm'] as num).toDouble(),
        );
      }
    } catch (e) {
      debugPrint('WeatherService error: $e');
    }
    return null;
  }
}
