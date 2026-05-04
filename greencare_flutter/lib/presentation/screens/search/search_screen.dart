import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/api_keys.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List _plants = [];
  bool _isLoading = false;
  Timer? _debounce;

  // Función de búsqueda con Debounce
  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _searchPlants(query);
      }
    });
  }

  Future<void> _searchPlants(String query) async {
    setState(() => _isLoading = true);
    
    final url = 'https://perenual.com/api/species-list?key=$perenualApiKey&q=$query';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _plants = data['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error buscando plantas: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Plantas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Ej: Aloe Vera...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          _isLoading 
            ? const LinearProgressIndicator() 
            : Expanded(
                child: ListView.builder(
                  itemCount: _plants.length,
                  itemBuilder: (context, index) {
                    final plant = _plants[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: plant['default_image']?['thumbnail'] ?? 'https://via.placeholder.com/150',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.eco),
                        ),
                      ),
                      title: Text(plant['common_name'] ?? 'Nombre desconocido'),
                      subtitle: Text(
                        (plant['scientific_name'] as List).join(', '),
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                      onTap: () {
                        // Navegar a detalle pasando el ID
                        Navigator.pushNamed(
                          context, 
                          '/details', 
                          arguments: plant['id']
                        );
                      },
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}