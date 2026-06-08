import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// Importaciones compartidas con otros servicios de la carpeta
import '../../../core/constants/app_config.dart';
import '../../../core/constants/care_schedule.dart';

/// Pido el tiempo para la ubicación de una planta al backend (usa Open-Meteo).
/// Si hay algún fallo devuelvo null para que la app use el intervalo base.
/// Así no se rompe el TFG si el servicio externo no responde.
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
