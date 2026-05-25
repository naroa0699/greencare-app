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

  Future<void> waterPlant(
    String userId,
    String plantId,
    String wateringType,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await _plantsRef(userId).doc(plantId).update({
      'lastWatered': Timestamp.fromDate(today),
      'nextWatering': Timestamp.fromDate(calculateNextWatering(wateringType)),
    });

    // Actualizar contadores
    final userRef = _db.collection('users').doc(userId);
    await userRef.set({
      'totalWaterings': FieldValue.increment(1),
      'lastWateringDate': Timestamp.fromDate(today),
    }, SetOptions(merge: true));

    // Guardar historial
    await _db
        .collection('users')
        .doc(userId)
        .collection('watering_history')
        .add({'plantId': plantId, 'wateredAt': Timestamp.fromDate(today)});

    // Comprobar si la racha avanza
    await updateStreak(userId);
  }

  Future<void> undoWatering(String userId, String plantId) async {
    await _plantsRef(userId).doc(plantId).update({
      'lastWatered': null,
      'nextWatering': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> updateStreak(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Obtener todas las plantas
    final plants = await getMyPlants(userId).first;

    // Plantas que tocaba regar hoy
    final plantsDueToday = plants.where((plant) {
      final next = DateTime(
        plant.nextWatering.year,
        plant.nextWatering.month,
        plant.nextWatering.day,
      );
      return next.isAtSameMomentAs(today) || next.isBefore(today);
    }).toList();

    // Si no tocaba regar ninguna hoy, no hacer nada
    if (plantsDueToday.isEmpty) return;

    // Comprobar si todas las que tocaban han sido regadas hoy
    final allWatered = plantsDueToday.every((plant) {
      final lw = plant.lastWatered;
      if (lw == null) return false;
      final lwDay = DateTime(lw.year, lw.month, lw.day);
      return lwDay.isAtSameMomentAs(today);
    });

    if (!allWatered) return;

    // Todas regadas — actualizar racha
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
      // diff == 0 ya se contó hoy
    }

    await userRef.set({
      'streak': streak,
      'lastStreakDate': Timestamp.fromDate(today),
    }, SetOptions(merge: true));
  }
}
