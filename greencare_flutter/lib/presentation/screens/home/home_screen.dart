import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';
import '../../../providers/auth_provider.dart' as app_auth;
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
    final user =
        context.watch<app_auth.AuthProvider>().user ??
        FirebaseAuth.instance.currentUser!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: kIsWeb
          ? null
          : AppBar(
              title: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(TablerIcons.leaf, size: 22),
                  SizedBox(width: 6),
                  Text('GreenCare'),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () => context.push('/profile'),
                ),
              ],
            ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: StreamBuilder<List<UserPlantModel>>(
            stream: _repo.getMyPlants(_userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final plants = snapshot.data ?? [];
              final urgent = plants
                  .where(
                    (p) =>
                        p.nextWatering.difference(DateTime.now()).inDays <= 0,
                  )
                  .toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!kIsWeb) ...[
                      Text(
                        'Hola, ${user.displayName?.isNotEmpty == true ? user.displayName! : user.email?.split('@').first ?? 'usuaria'}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '¿Cómo están tus plantas hoy?',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                    ] else ...[
                      Text(
                        'Bienvenida, ${user.displayName?.isNotEmpty == true ? user.displayName! : user.email?.split('@').first ?? 'usuaria'}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '¿Cómo están tus plantas hoy?',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Racha
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(_userId)
                          .snapshots(),
                      builder: (context, userSnapshot) {
                        final data =
                            userSnapshot.data?.data()
                                as Map<String, dynamic>? ??
                            {};
                        final streak = data['streak'] ?? 0;
                        if (streak == 0) return const SizedBox.shrink();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: scheme.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(TablerIcons.flame, color: Colors.orange, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                '¡Llevas $streak día${streak == 1 ? '' : 's'} de racha!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Quick cards
                    Row(
                      children: [
                        _QuickCard(
                          icon: Icons.calendar_month_outlined,
                          label: 'Calendario\nde cuidados',
                          color: scheme.primary,
                          onTap: () => context.go('/calendar'),
                        ),
                        const SizedBox(width: 12),
                        _QuickCard(
                          icon: Icons.smart_toy_outlined,
                          label: 'Preguntar\na GreenBot',
                          color: scheme.secondary,
                          onTap: () => context.go('/chatbot'),
                        ),
                        const SizedBox(width: 12),
                        _QuickCard(
                          icon: Icons.forum_outlined,
                          label: 'Ver\ncomunidad',
                          color: scheme.tertiary,
                          onTap: () => context.go('/forum'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Icon(TablerIcons.droplet, color: scheme.secondary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Necesitan agua hoy',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (urgent.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(TablerIcons.circle_check, color: scheme.primary),
                            const SizedBox(width: 8),
                            const Expanded(
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
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) =>
                              _UrgentPlantChip(plant: urgent[index]),
                        ),
                      ),
                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(TablerIcons.plant, color: scheme.primary, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'Mis plantas',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                            ),
                          ],
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
                            border: Border.all(
                              color: scheme.outline.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  size: 40,
                                  color: scheme.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Añade tu primera planta',
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                  ),
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
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: kIsWeb ? 3 : 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: kIsWeb ? 2.5 : 1.4,
                        ),
                        itemCount: plants.take(kIsWeb ? 6 : 4).length,
                        itemBuilder: (context, index) {
                          final plant = plants[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Icon(
                                    TablerIcons.plant,
                                    color: scheme.primary,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          plant.nickname ?? plant.commonName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Riego: ${plant.watering}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: scheme.onSurfaceVariant,
                                          ),
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
        ),
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
          padding: EdgeInsets.symmetric(vertical: kIsWeb ? 20 : 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: kIsWeb ? 32 : 28),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: kIsWeb ? 13 : 11,
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
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(TablerIcons.droplet, color: scheme.secondary, size: 28),
          const SizedBox(height: 6),
          Text(
            plant.nickname ?? plant.commonName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: scheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
