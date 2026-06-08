import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../data/repositories/user_plant_repository.dart';
import '../../../data/models/user_plant_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<UserPlantModel> _allPlants = [];
  StreamSubscription<List<UserPlantModel>>? _plantsSub;
  int _calendarKey = 0;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadPlants();
  }

  @override
  void dispose() {
    _plantsSub?.cancel();
    super.dispose();
  }

  void _loadPlants() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    debugPrint('Escuchando plantas de usuario: $userId');
    _plantsSub = UserPlantRepository().getMyPlants(userId).listen((plants) {
      debugPrint(
        'Plantas actualizadas: ${plants.map((p) => '${p.commonName}: ${p.nextWatering}').join(', ')}',
      );
      if (mounted) {
        setState(() {
          _allPlants = plants;
          _calendarKey++;
        });
      }
    });
  }

  int _intervalDays(String watering) {
    switch (watering.toLowerCase()) {
      case 'frequent':
        return 2;
      case 'average':
        return 5;
      case 'minimum':
        return 10;
      default:
        return 30;
    }
  }

  List<UserPlantModel> _plantsForDay(DateTime day) {
    final dayNorm = DateTime(day.year, day.month, day.day);
    return _allPlants.where((plant) {
      // Normalizo nextWatering a la zona local para comparar por días.
      final nextLocal = plant.nextWatering.toLocal();
      final next = DateTime(nextLocal.year, nextLocal.month, nextLocal.day);
      final diff = dayNorm.difference(next).inDays;
      if (diff < 0) return false;
      final interval = _intervalDays(plant.watering);
      return diff % interval == 0;
    }).toList();
  }

  bool _isWateredOn(UserPlantModel plant, DateTime day) {
    final lw = plant.lastWatered;
    if (lw == null) return false;
    return isSameDay(lw, day);
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final repo = UserPlantRepository();
    final scheme = Theme.of(context).colorScheme;

    final selectedPlants = _selectedDay != null
        ? _plantsForDay(_selectedDay!)
        : <UserPlantModel>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Calendario de cuidados')),
      body: Column(
        children: [
          TableCalendar<UserPlantModel>(
            key: ValueKey(_calendarKey),
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _plantsForDay,
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const Divider(),

          Expanded(
            child: selectedPlants.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 60,
                          color: scheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nada que hacer este día',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: selectedPlants.length,
                    itemBuilder: (context, index) {
                      final plant = selectedPlants[index];
                      final isToday = isSameDay(_selectedDay!, DateTime.now());
                      final watered = _isWateredOn(plant, _selectedDay!);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: watered
                                ? Colors.green
                                : scheme.primary,
                            child: Icon(
                              watered ? Icons.check : Icons.water_drop,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            plant.nickname ?? plant.commonName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            watered
                                ? 'Regada ✅'
                                : isToday
                                ? 'Riego: ${plant.watering}'
                                : 'Pendiente de riego',
                            style: TextStyle(
                              color: watered
                                  ? Colors.green
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: watered
                              ? Chip(
                                  label: const Text(
                                    '✅ Hecho',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: scheme.primaryContainer,
                                )
                              : ElevatedButton.icon(
                                  onPressed: !isToday
                                      ? null
                                      : () async {
                                          try {
                                            await repo.waterPlant(
                                              userId,
                                              plant.id,
                                              plant.watering,
                                            );
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${plant.nickname ?? plant.commonName} regada 💧',
                                                  ),
                                                  duration: const Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            debugPrint('ERROR al regar: $e');
                                          }
                                        },
                                  icon: const Icon(Icons.water_drop, size: 16),
                                  label: Text(isToday ? 'Regar' : 'Pendiente'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isToday
                                        ? scheme.primary
                                        : Colors.grey.shade300,
                                    foregroundColor: isToday
                                        ? Colors.white
                                        : Colors.grey,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    textStyle: const TextStyle(fontSize: 12),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
