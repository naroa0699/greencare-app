import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/api_keys.dart';
import '../../../data/services/chatbot_service.dart';

/// Pantalla de búsqueda de plantas.
/// Hace llamadas a Perenual y usa GreenBot para completar imágenes o
/// traducir consultas si hace falta. Es la vista que uso para encontrar
/// especies en el TFG.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> _plants = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  Timer? _debounce;
  final _searchController = TextEditingController();

  final List<String> _suggestions = [
    'Aloe vera',
    'Monstera',
    'Pothos',
    'Cactus',
    'Lavanda',
    'Orquídea',
    'Bambú',
    'Rosa',
  ];

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _searchPlants(query);
      } else {
        setState(() {
          _plants = [];
          _hasSearched = false;
        });
      }
    });
  }

  Future<void> _searchPlants(String query) async {
    setState(() => _isLoading = true);

    String searchQuery = query;
    try {
      final translated = await ChatbotService().translateToEnglish(query);
      if (translated != null) searchQuery = translated;
    } catch (e) {
      debugPrint('Traducción no disponible: $e');
    }

    final url =
        'https://perenual.com/api/species-list?key=$perenualApiKey&q=$searchQuery';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final plants = List<dynamic>.from(data['data'] ?? []);

        await Future.wait(
          plants.map((plant) async {
            final img = plant['default_image']?['medium_url'] as String?;
            if (img == null ||
                img.contains('upgrade_access') ||
                img.contains('perenual')) {
              final scientificName =
                  (plant['scientific_name'] as List?)?.first as String?;
              if (scientificName != null) {
                final wikiImage = await ChatbotService().getWikimediaImage(
                  scientificName,
                );
                if (wikiImage != null) {
                  plant['default_image'] = {'medium_url': wikiImage};
                }
              }
            }
          }),
        );

        setState(() {
          _plants = plants;
          _hasSearched = true;
        });
      }
    } catch (e) {
      debugPrint('Error buscando plantas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: kIsWeb ? null : AppBar(title: const Text('Buscar Plantas')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              if (kIsWeb) const SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  kIsWeb ? 24 : 16,
                  12,
                  kIsWeb ? 24 : 16,
                  8,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Busca aloe vera, monstera...',
                    prefixIcon: Icon(Icons.search, color: scheme.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _plants = [];
                                _hasSearched = false;
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: scheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: scheme.outline.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: scheme.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: scheme.surfaceContainerHighest,
                  ),
                  onChanged: (value) {
                    setState(() {});
                    _onSearchChanged(value);
                  },
                ),
              ),

              if (_isLoading)
                LinearProgressIndicator(color: scheme.primary)
              else
                const SizedBox(height: 4),

              Expanded(
                child: !_hasSearched && _plants.isEmpty
                    ? _buildSuggestions(scheme)
                    : _plants.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: scheme.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron plantas',
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Prueba con otro nombre',
                              style: TextStyle(
                                color: scheme.onSurfaceVariant.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.all(kIsWeb ? 24 : 16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: kIsWeb ? 4 : 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: kIsWeb ? 0.75 : 0.8,
                        ),
                        itemCount: _plants.length,
                        itemBuilder: (context, index) {
                          final plant = _plants[index];
                          return _PlantCard(
                            plant: plant,
                            onTap: () =>
                                context.push('/details/${plant['id']}'),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions(ColorScheme scheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(kIsWeb ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🌱 Búsquedas populares',
            style: TextStyle(
              fontSize: kIsWeb ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((suggestion) {
              return ActionChip(
                label: Text(suggestion),
                avatar: Icon(Icons.eco, size: 16, color: scheme.primary),
                backgroundColor: scheme.primaryContainer,
                labelStyle: TextStyle(color: scheme.onPrimaryContainer),
                onPressed: () {
                  _searchController.text = suggestion;
                  _searchPlants(suggestion);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          Text(
            '💡 Consejo',
            style: TextStyle(
              fontSize: kIsWeb ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: scheme.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Busca por nombre común o científico. Si los datos de cuidado no están disponibles, GreenBot los completará automáticamente.',
                    style: TextStyle(
                      color: scheme.onSecondaryContainer,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final dynamic plant;
  final VoidCallback onTap;

  const _PlantCard({required this.plant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: CachedNetworkImage(
                imageUrl:
                    plant['default_image']?['medium_url'] ??
                    'https://placehold.co/300x300/png',
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: scheme.primaryContainer,
                  child: Center(
                    child: Icon(Icons.eco, size: 40, color: scheme.primary),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: scheme.primaryContainer,
                  child: Center(
                    child: Icon(Icons.eco, size: 40, color: scheme.primary),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      plant['common_name'] ?? 'Sin nombre',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: scheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (plant['scientific_name'] as List?)?.join(', ') ?? '',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (plant['watering'] != null)
                      Row(
                        children: [
                          Icon(
                            Icons.water_drop,
                            size: 12,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            plant['watering'],
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
