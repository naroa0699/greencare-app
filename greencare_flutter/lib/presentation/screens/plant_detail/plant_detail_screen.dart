import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../../core/constants/api_keys.dart';
import '../../../data/repositories/user_plant_repository.dart';
import '../../../data/models/user_plant_model.dart';
import '../../../core/constants/care_schedule.dart';
import '../../../data/services/chatbot_service.dart';

class PlantDetailScreen extends StatefulWidget {
  final int plantId;
  const PlantDetailScreen({super.key, required this.plantId});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  Map<String, dynamic>? _plant;
  bool _isLoading = true;
  bool _alreadyAdded = false;
  bool _isAdding = false;
  bool _wateredToday = false;
  DateTime? _lastWatered;

  @override
  void initState() {
    super.initState();
    _fetchPlantDetail();
  }

  bool _isWateredToday(DateTime? lastWatered) {
    if (lastWatered == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lw = DateTime(lastWatered.year, lastWatered.month, lastWatered.day);
    return lw.isAtSameMomentAs(today);
  }

  Future<void> _fetchPlantDetail() async {
    final url =
        'https://perenual.com/api/species/details/${widget.plantId}?key=$perenualApiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Fallback de cuidados con Gemini — solo si backend está disponible
        try {
          if (data['watering'] == null ||
              data['sunlight'] == null ||
              data['cycle'] == null) {
            final plantName = data['common_name'] ?? 'planta desconocida';
            final care = await ChatbotService().getPlantCare(plantName);
            data['watering'] ??= care['watering'];
            data['sunlight'] ??= [care['sunlight']];
            data['cycle'] ??= care['cycle'];
          }
        } catch (e) {
          debugPrint('Gemini fallback no disponible: $e');
          data['watering'] ??= 'Average';
          data['sunlight'] ??= ['part shade'];
          data['cycle'] ??= 'Perennial';
        }

        // Imagen con Wikimedia como fallback
        try {
          final perenualImage =
              data['default_image']?['original_url'] as String?;
          if (perenualImage == null ||
              perenualImage.contains('upgrade_access') ||
              perenualImage.contains('perenual')) {
            final scientificName =
                (data['scientific_name'] as List?)?.first as String?;
            if (scientificName != null) {
              final wikiImage = await ChatbotService().getWikimediaImage(
                scientificName,
              );
              if (wikiImage != null) {
                data['default_image'] = {'original_url': wikiImage};
              }
            }
          }
        } catch (e) {
          debugPrint('Wikimedia fallback error: $e');
        }

        final userId = FirebaseAuth.instance.currentUser!.uid;
        final repo = UserPlantRepository();
        final plants = await repo.getMyPlants(userId).first;
        final match = plants
            .where((p) => p.id == data['id'].toString())
            .toList();
        final alreadyAdded = match.isNotEmpty;
        final lastWatered = alreadyAdded ? match.first.lastWatered : null;

        setState(() {
          _plant = data;
          _alreadyAdded = alreadyAdded;
          _lastWatered = lastWatered;
          _wateredToday = _isWateredToday(lastWatered);
        });
      }
    } catch (e) {
      debugPrint('Error cargando detalle: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addPlant() async {
    if (_alreadyAdded || _isAdding) return;
    setState(() => _isAdding = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final repo = UserPlantRepository();

      final plant = UserPlantModel(
        id: _plant!['id'].toString(),
        commonName: _plant!['common_name'] ?? 'Sin nombre',
        imageUrl: _plant!['default_image']?['medium_url'],
        watering: _plant!['watering'] ?? 'Average',
        addedAt: DateTime.now(),
        nextWatering: calculateNextWatering(_plant!['watering'] ?? 'Average'),
      );

      await repo.addPlant(userId, plant);

      if (mounted) {
        setState(() {
          _alreadyAdded = true;
          _isAdding = false;
          _wateredToday = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Planta añadida a tu colección! 🌿')),
        );
      }
    } catch (e) {
      debugPrint('Error añadiendo planta: $e');
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _waterPlant() async {
    if (_wateredToday) return;

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final repo = UserPlantRepository();

    setState(() => _wateredToday = true);

    await repo.waterPlant(
      userId,
      _plant!['id'].toString(),
      _plant!['watering'] ?? 'Average',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Planta regada! 💧'),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () async {
              // Restaurar lastWatered anterior
              setState(() => _wateredToday = false);
              if (_lastWatered != null) {
                await repo.updateNextWatering(
                  userId,
                  _plant!['id'].toString(),
                  calculateNextWatering(_plant!['watering'] ?? 'Average'),
                );
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Cargando datos de la planta...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : _plant == null
          ? const Center(child: Text('No se pudo cargar la planta.'))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      _plant!['common_name'] ?? 'Sin nombre',
                      style: const TextStyle(fontSize: 16),
                    ),
                    background: CachedNetworkImage(
                      imageUrl:
                          _plant!['default_image']?['original_url'] ??
                          'https://placehold.co/400x280/png',
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.eco, size: 80),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (_plant!['scientific_name'] as List?)?.join(', ') ??
                              '',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Cuidados',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _CareCard(
                              icon: Icons.water_drop,
                              label: 'Riego',
                              value: _plant!['watering'] ?? 'No disponible',
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 12),
                            _CareCard(
                              icon: Icons.wb_sunny,
                              label: 'Luz',
                              value:
                                  (_plant!['sunlight'] as List?)?.first ??
                                  'No disponible',
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 12),
                            _CareCard(
                              icon: Icons.loop,
                              label: 'Ciclo',
                              value: _plant!['cycle'] ?? 'No disponible',
                              color: Colors.green,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (_plant!['description'] != null) ...[
                          const Text(
                            'Descripción',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _plant!['description'],
                            style: const TextStyle(fontSize: 15, height: 1.5),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Botón añadir
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _alreadyAdded || _isAdding
                                ? null
                                : _addPlant,
                            icon: _isAdding
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(_alreadyAdded ? Icons.check : Icons.add),
                            label: Text(
                              _alreadyAdded
                                  ? 'Ya añadida a tu colección'
                                  : 'Añadir a Mis Plantas',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: _alreadyAdded
                                  ? Colors.grey.shade300
                                  : null,
                            ),
                          ),
                        ),

                        // Botón regar
                        if (_alreadyAdded) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _wateredToday ? null : _waterPlant,
                              icon: Icon(
                                _wateredToday ? Icons.check : Icons.water_drop,
                              ),
                              label: Text(
                                _wateredToday
                                    ? 'Ya regada hoy ✅'
                                    : 'Marcar como regada',
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                backgroundColor: _wateredToday
                                    ? Colors.grey.shade300
                                    : Colors.blue,
                                foregroundColor: _wateredToday
                                    ? Colors.grey
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CareCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _CareCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
