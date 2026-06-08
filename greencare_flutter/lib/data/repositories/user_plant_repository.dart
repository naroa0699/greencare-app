import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_plant_model.dart';
import '../../core/constants/care_schedule.dart';

class UserPlantRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _plantsRef(String userId) =>
      _db.collection('users').doc(userId).collection('my_plants');

  Stream<List<UserPlantModel>> getMyPlants(String userId) {
    return _plantsRef(userId).snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => UserPlantModel.fromFirestore(doc))
          .toList(),
    );
  }

  Future<void> addPlant(String userId, UserPlantModel plant) async {
    await _plantsRef(userId).doc(plant.id).set(plant.toMap());
  }

  Future<void> deletePlant(String userId, String plantId) async {
    await _plantsRef(userId).doc(plantId).delete();
  }

  Future<void> updateNextWatering(
    String userId,
    String plantId,
    DateTime date,
  ) async {
    await _plantsRef(
      userId,
    ).doc(plantId).update({'nextWatering': Timestamp.fromDate(date)});
  }

  Future<void> updateLocation(
    String userId,
    String plantId,
    double latitude,
    double longitude,
  ) async {
    await _plantsRef(
      userId,
    ).doc(plantId).update({'latitude': latitude, 'longitude': longitude});
  }

  Future<void> waterPlant(
    String userId,
    String plantId,
    String wateringType, {
    WeatherData? weather,
  }) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      debugPrint('Regando planta $plantId...');

      // Cojo la fecha 'nextWatering' actual y calculo la próxima a partir de ahí
      final plantDoc = await _plantsRef(userId).doc(plantId).get();
      final plantData = plantDoc.data() as Map<String, dynamic>;
      final currentNextWatering = (plantData['nextWatering'] as Timestamp)
          .toDate();
      final base = DateTime(
        currentNextWatering.year,
        currentNextWatering.month,
        currentNextWatering.day,
      );

      await _plantsRef(userId).doc(plantId).update({
        'lastWatered': Timestamp.fromDate(today),
        'nextWatering': Timestamp.fromDate(
          calculateNextWatering(wateringType, weather: weather, from: base),
        ),
      });

      debugPrint('nextWatering actualizado OK');

      final userRef = _db.collection('users').doc(userId);
      await userRef.set({
        'totalWaterings': FieldValue.increment(1),
        'lastWateringDate': Timestamp.fromDate(today),
      }, SetOptions(merge: true));

      debugPrint('contadores actualizados OK');

      await _db
          .collection('users')
          .doc(userId)
          .collection('watering_history')
          .add({'plantId': plantId, 'wateredAt': Timestamp.fromDate(today)});

      debugPrint('historial guardado OK');

      await updateStreak(userId);

      debugPrint('racha actualizada OK');
    } catch (e) {
      debugPrint('ERROR en waterPlant: $e');
      rethrow;
    }
  }

  Future<void> undoWatering(String userId, String plantId) async {
    await _plantsRef(userId).doc(plantId).update({
      'lastWatered': null,
      'nextWatering': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> fertilizePlant(
    String userId,
    String plantId, {
    int everyDays = 30,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await _plantsRef(userId).doc(plantId).update({
      'lastFertilized': Timestamp.fromDate(today),
      'nextFertilizing': Timestamp.fromDate(
        today.add(Duration(days: everyDays)),
      ),
    });
  }

  Future<void> updateStreak(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final plants = await getMyPlants(userId).first;

    final plantsDueToday = plants.where((plant) {
      final next = DateTime(
        plant.nextWatering.year,
        plant.nextWatering.month,
        plant.nextWatering.day,
      );
      return next.isAtSameMomentAs(today) || next.isBefore(today);
    }).toList();

    if (plantsDueToday.isEmpty) return;

    final allWatered = plantsDueToday.every((plant) {
      final lw = plant.lastWatered;
      if (lw == null) return false;
      final lwDay = DateTime(lw.year, lw.month, lw.day);
      return lwDay.isAtSameMomentAs(today);
    });

    if (!allWatered) return;

    final userRef = _db.collection('users').doc(userId);
    final userDoc = await userRef.get();
    final data = userDoc.exists
        ? (userDoc.data() as Map<String, dynamic>)
        : <String, dynamic>{};

    int streak = data['streak'] ?? 0;
    final lastStreakDate = data['lastStreakDate'] != null
        ? (data['lastStreakDate'] as Timestamp).toDate()
        : null;

    if (lastStreakDate == null) {
      streak = 1;
    } else {
      final lastDay = DateTime(
        lastStreakDate.year,
        lastStreakDate.month,
        lastStreakDate.day,
      );
      final diff = today.difference(lastDay).inDays;
      if (diff == 1) {
        streak += 1;
      } else if (diff > 1) {
        streak = 1;
      }
    }

    await userRef.set({
      'streak': streak,
      'lastStreakDate': Timestamp.fromDate(today),
    }, SetOptions(merge: true));
  }
}
