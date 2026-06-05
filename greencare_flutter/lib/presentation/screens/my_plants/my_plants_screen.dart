import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/user_plant_repository.dart';
import '../../../data/models/user_plant_model.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/weather_service.dart';
import '../../../core/constants/care_schedule.dart';

class MyPlantsScreen extends StatelessWidget {
  const MyPlantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final repo = UserPlantRepository();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: kIsWeb ? null : AppBar(title: const Text('Mis Plantas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/search'),
        icon: const Icon(Icons.add),
        label: const Text('Añadir planta'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: StreamBuilder<List<UserPlantModel>>(
            stream: repo.getMyPlants(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final plants = snapshot.data ?? [];
              if (plants.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.eco_outlined,
                        size: 80,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aún no tienes plantas',
                        style: TextStyle(
                          fontSize: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pulsa + para añadir una',
                        style: TextStyle(
                          fontSize: 14,
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/search'),
                        icon: const Icon(Icons.search),
                        label: const Text('Buscar plantas'),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: EdgeInsets.all(kIsWeb ? 24 : 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: kIsWeb ? 4 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: kIsWeb ? 0.75 : 0.85,
                ),
                itemCount: plants.length,
                itemBuilder: (context, index) {
                  final plant = plants[index];
                  return _PlantCard(plant: plant, userId: userId, repo: repo);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final UserPlantModel plant;
  final String userId;
  final UserPlantRepository repo;

  const _PlantCard({
    required this.plant,
    required this.userId,
    required this.repo,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final daysLeft = plant.nextWatering.difference(DateTime.now()).inDays;
    final needsWater = daysLeft <= 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastWatered = plant.lastWatered;
    final wateredToday =
        lastWatered != null &&
        DateTime(
          lastWatered.year,
          lastWatered.month,
          lastWatered.day,
        ).isAtSameMomentAs(today);

    return GestureDetector(
      onTap: () => context.push('/details/${plant.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  plant.imageUrl != null
                      ? Image.network(
                          plant.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => Container(
                            color: scheme.primaryContainer,
                            child: Center(
                              child: Icon(
                                Icons.eco,
                                size: 60,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: scheme.primaryContainer,
                          child: Center(
                            child: Icon(
                              Icons.eco,
                              size: 60,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                  if (needsWater && !wateredToday)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.water_drop,
                              color: Colors.white,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '¡Riega!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (wateredToday)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              '¡Regada!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.nickname ?? plant.commonName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    wateredToday
                        ? '✅ Regada hoy'
                        : needsWater
                        ? 'Necesita agua hoy'
                        : 'Regar en $daysLeft día${daysLeft == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 11,
                      color: wateredToday
                          ? Colors.green
                          : needsWater
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Botones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: wateredToday
                          ? null
                          : () async {
                              // Ajuste por clima si la planta tiene ubicacion
                              WeatherData? weather;
                              if (plant.latitude != null &&
                                  plant.longitude != null) {
                                weather = await WeatherService().getWeather(
                                  plant.latitude!,
                                  plant.longitude!,
                                );
                              }
                              await repo.waterPlant(
                                userId,
                                plant.id,
                                plant.watering,
                                weather: weather,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${plant.nickname ?? plant.commonName} regada 💧',
                                    ),
                                    action: SnackBarAction(
                                      label: 'Deshacer',
                                      onPressed: () async {
                                        await repo.undoWatering(
                                          userId,
                                          plant.id,
                                        );
                                      },
                                    ),
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              }
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: wateredToday
                              ? scheme.surfaceContainerHighest
                              : needsWater
                              ? scheme.primary
                              : scheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              wateredToday ? Icons.check : Icons.water_drop,
                              size: 14,
                              color: wateredToday
                                  ? scheme.onSurfaceVariant
                                  : needsWater
                                  ? scheme.onPrimary
                                  : scheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              wateredToday
                                  ? 'Ya regada hoy'
                                  : needsWater
                                  ? '¡Regar!'
                                  : 'Regar',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: wateredToday
                                    ? scheme.onSurfaceVariant
                                    : needsWater
                                    ? scheme.onPrimary
                                    : scheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: () => _confirmDelete(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar planta'),
        content: Text(
          '¿Seguro que quieres eliminar "${plant.nickname ?? plant.commonName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await repo.deletePlant(userId, plant.id);
              await NotificationService().cancelNotification(
                plant.id.hashCode.abs(),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
