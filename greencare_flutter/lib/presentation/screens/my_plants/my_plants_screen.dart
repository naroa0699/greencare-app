import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/user_plant_repository.dart';
import '../../../data/models/user_plant_model.dart';
import '../../../data/services/notification_service.dart';

class MyPlantsScreen extends StatelessWidget {
  const MyPlantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final repo = UserPlantRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Plantas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/search'),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<UserPlantModel>>(
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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aún no tienes plantas',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pulsa + para añadir una',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              return _PlantCard(plant: plant, userId: userId, repo: repo);
            },
          );
        },
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
    final daysLeft = plant.nextWatering.difference(DateTime.now()).inDays;
    final needsWater = daysLeft <= 0;

    return GestureDetector(
      onTap: () => context.push('/details/${plant.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  plant.imageUrl != null
                      ? Image.network(
                          plant.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              const Icon(Icons.eco, size: 60),
                        )
                      : const Icon(Icons.eco, size: 60),
                  if (needsWater)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.water_drop,
                                color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              '¡Riega!',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.nickname ?? plant.commonName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    needsWater
                        ? 'Necesita agua hoy'
                        : 'Regar en $daysLeft día${daysLeft == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 11,
                      color: needsWater ? Colors.blue : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Botones regar y eliminar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await repo.waterPlant(
                            userId, plant.id, plant.watering);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${plant.nickname ?? plant.commonName} regada 💧',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: needsWater
                              ? Colors.blue
                              : Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.water_drop,
                              size: 14,
                              color: needsWater ? Colors.white : Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              needsWater ? '¡Regar!' : 'Regar',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color:
                                    needsWater ? Colors.white : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
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
            '¿Seguro que quieres eliminar "${plant.nickname ?? plant.commonName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await repo.deletePlant(userId, plant.id);
              await NotificationService().cancelNotification(plant.id.hashCode.abs());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}