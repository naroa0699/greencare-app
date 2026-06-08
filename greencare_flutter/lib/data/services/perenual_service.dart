import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/plant_model.dart';
import '../../core/constants/api_keys.dart';

/// Servicio para buscar plantas en la API de Perenual.
/// Devuelve `PlantModel` usado en la app del TFG.
class PerenualService {
  static const String _baseUrl = 'https://perenual.com/api';

  Future<List<PlantModel>> searchPlants(String query) async {
    final url = Uri.parse(
      '$_baseUrl/species-list?key=$perenualApiKey&q=$query'
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['data'];
      return results.map((json) => PlantModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al buscar plantas: ${response.statusCode}');
    }
  }

  Future<PlantModel> getPlantDetail(int id) async {
    final url = Uri.parse('$_baseUrl/species/details/$id?key=$perenualApiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return PlantModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener detalle');
    }
  }
}