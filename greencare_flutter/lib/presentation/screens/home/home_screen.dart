import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:go_router/go_router.dart';
import '../../../data/repositories/user_plant_repository.dart';
import '../../../data/models/user_plant_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final String _userId;
  late final UserPlantRepository _repo;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser!.uid;
    _repo = UserPlantRepository();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌿 GreenCare'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: StreamBuilder<List<UserPlantModel>>(
        stream: _repo.getMyPlants(_userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final plants = snapshot.data ?? [];
          final urgent = plants
              .where((p) => p.nextWatering.difference(DateTime.now()).inDays <= 0)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, ${user.email?.split('@').first ?? 'usuaria'} 👋',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  '¿Cómo están tus plantas hoy?',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    _QuickCard(
                      icon: Icons.calendar_month_outlined,
                      label: 'Calendario\nde cuidados',
                      color: Colors.purple,
                      onTap: () => context.go('/calendar'),
                    ),
                    const SizedBox(width: 12),
                    _QuickCard(
                      icon: Icons.smart_toy_outlined,
                      label: 'Preguntar\na GreenBot',
                      color: Colors.teal,
                      onTap: () => context.go('/chatbot'),
                    ),
                    const SizedBox(width: 12),
                    _QuickCard(
                      icon: Icons.forum_outlined,
                      label: 'Ver\ncomunidad',
                      color: Colors.orange,
                      onTap: () => context.go('/forum'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                const Text(
                  '💧 Necesitan agua hoy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (urgent.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '¡Todo en orden! Ninguna planta necesita agua hoy.',
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: urgent.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) =>
                          _UrgentPlantChip(plant: urgent[index]),
                    ),
                  ),
                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🪴 Mis plantas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => context.go('/my-plants'),
                      child: const Text('Ver todas'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (plants.isEmpty)
                  GestureDetector(
                    onTap: () => context.go('/my-plants'),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(Icons.add_circle_outline, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'Añade tu primera planta',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: plants.take(4).length,
                    itemBuilder: (context, index) {
                      final plant = plants[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.eco, color: Colors.green, size: 32),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      plant.nickname ?? plant.commonName,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Riego: ${plant.watering}',
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
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
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UrgentPlantChip extends StatelessWidget {
  final UserPlantModel plant;

  const _UrgentPlantChip({required this.plant});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.water_drop, color: Colors.blue, size: 28),
          const SizedBox(height: 6),
          Text(
            plant.nickname ?? plant.commonName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
