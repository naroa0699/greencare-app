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
  final Map<String, bool> _wateredToday = {};

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
    _plantsSub = UserPlantRepository().getMyPlants(userId).listen((plants) {
      if (mounted) setState(() => _allPlants = plants);
    });
  }

  String _dayKey(String plantId, DateTime day) =>
      '${plantId}_${day.year}_${day.month}_${day.day}';

  List<UserPlantModel> _plantsForDay(DateTime day) {
    return _allPlants.where((plant) {
      int interval;
      switch (plant.watering.toLowerCase()) {
        case 'frequent':
          interval = 2;
          break;
        case 'average':
          interval = 5;
          break;
        case 'minimum':
          interval = 10;
          break;
        default:
          interval = 30;
          break;
      }
      final start = plant.nextWatering;
      final diff = day
          .difference(DateTime(start.year, start.month, start.day))
          .inDays;
      return diff >= 0 && diff % interval == 0;
    }).toList();
  }

  List<UserPlantModel> _getEventsForDay(DateTime day) => _plantsForDay(day);

  bool _isWateredOn(UserPlantModel plant, DateTime selectedDay) {
    if (!isSameDay(selectedDay, DateTime.now())) return false;

    final key = _dayKey(plant.id, DateTime.now());
    if (_wateredToday[key] == true) return true;

    final lw = plant.lastWatered;
    if (lw == null) return false;
    return isSameDay(lw, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final repo = UserPlantRepository();

    final selectedPlants = _selectedDay != null
        ? _plantsForDay(_selectedDay!)
        : <UserPlantModel>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Calendario de cuidados')),
      body: Column(
        children: [
          TableCalendar<UserPlantModel>(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.4),
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
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 60,
                          color: Colors.green,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Nada que hacer este dia',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: selectedPlants.length,
                    itemBuilder: (context, index) {
                      final plant = selectedPlants[index];
                      final selected = _selectedDay!;
                      final isToday = isSameDay(selected, DateTime.now());
                      final watered = _isWateredOn(plant, selected);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: watered
                                ? Colors.green
                                : Colors.blue,
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
                                ? 'Regada hoy ✅'
                                : isToday
                                ? 'Riego: ${plant.watering}'
                                : 'Pendiente de riego',
                            style: TextStyle(
                              color: watered ? Colors.green : Colors.grey,
                            ),
                          ),
                          trailing: watered
                              ? const Chip(
                                  label: Text(
                                    '✅ Hecho',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: Color(0xFFE8F5E9),
                                )
                              : ElevatedButton.icon(
                                  onPressed: !isToday
                                      ? null
                                      : () async {
                                          final key = _dayKey(
                                            plant.id,
                                            DateTime.now(),
                                          );
                                          setState(
                                            () => _wateredToday[key] = true,
                                          );
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
                                        },
                                  icon: const Icon(Icons.water_drop, size: 16),
                                  label: Text(isToday ? 'Regar' : 'Pendiente'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isToday
                                        ? Colors.blue
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
