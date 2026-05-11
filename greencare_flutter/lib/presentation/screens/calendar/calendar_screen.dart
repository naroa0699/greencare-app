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

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadPlants();
  }

  void _loadPlants() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    UserPlantRepository().getMyPlants(userId).listen((plants) {
      if (mounted) setState(() => _allPlants = plants);
    });
  }

  // Plantas que necesitan riego en un día concreto
  List<UserPlantModel> _plantsForDay(DateTime day) {
    return _allPlants.where((plant) {
      final d = plant.nextWatering;
      return d.year == day.year && d.month == day.month && d.day == day.day;
    }).toList();
  }

  // ¿Hay eventos ese día?
  List<UserPlantModel> _getEventsForDay(DateTime day) => _plantsForDay(day);

  @override
  Widget build(BuildContext context) {
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
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
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

          // Lista de plantas para el día seleccionado
          Expanded(
            child: selectedPlants.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 60, color: Colors.green),
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
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.water_drop,
                                color: Colors.white, size: 20),
                          ),
                          title: Text(
                            plant.nickname ?? plant.commonName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Riego: ${plant.watering}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: const Icon(
                            Icons.water_drop_outlined,
                            color: Colors.blue,
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