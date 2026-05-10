import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/api_keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/user_plant_repository.dart';
import '../../../data/models/user_plant_model.dart';
import '../../../core/constants/care_schedule.dart';

class PlantDetailScreen extends StatefulWidget {
  final int plantId;
  const PlantDetailScreen({super.key, required this.plantId});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  Map<String, dynamic>? _plant;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlantDetail();
  }

  Future<void> _fetchPlantDetail() async {
    final url =
        'https://perenual.com/api/species/details/${widget.plantId}?key=$perenualApiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() => _plant = json.decode(response.body));
      }
    } catch (e) {
      debugPrint('Error cargando detalle: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plant == null
          ? const Center(child: Text('No se pudo cargar la planta.'))
          : CustomScrollView(
              slivers: [
                // Imagen grande en la cabecera
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
                        // Nombre científico
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

                        // Tarjetas de cuidado
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
                              value: _plant!['watering'] ?? 'N/D',
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 12),
                            _CareCard(
                              icon: Icons.wb_sunny,
                              label: 'Luz',
                              value:
                                  (_plant!['sunlight'] as List?)?.first ??
                                  'N/D',
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 12),
                            _CareCard(
                              icon: Icons.loop,
                              label: 'Ciclo',
                              value: _plant!['cycle'] ?? 'N/D',
                              color: Colors.green,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Descripción
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

                        // Botón añadir a Mis Plantas
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final userId =
                                  FirebaseAuth.instance.currentUser!.uid;
                              final repo = UserPlantRepository();

                              final plant = UserPlantModel(
                                id: _plant!['id'].toString(),
                                commonName:
                                    _plant!['common_name'] ?? 'Sin nombre',
                                imageUrl:
                                    _plant!['default_image']?['medium_url'],
                                watering: _plant!['watering'] ?? 'Average',
                                addedAt: DateTime.now(),
                                nextWatering: calculateNextWatering(
                                  _plant!['watering'] ?? 'Average',
                                ),
                              );

                              await repo.addPlant(userId, plant);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '¡Planta añadida a tu colección! 🌿',
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Añadir a Mis Plantas'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
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

// Widget reutilizable para cada tarjeta de cuidado
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
