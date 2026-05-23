import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_plant_model.dart';
import '../../core/constants/care_schedule.dart';

class UserPlantRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _plantsRef(String userId) =>
      _db.collection('users').doc(userId).collection('my_plants');

  Stream<List<UserPlantModel>> getMyPlants(String userId) {
    return _plantsRef(userId).snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => UserPlantModel.fromFirestore(doc))
            .toList());
  }

  Future<void> addPlant(String userId, UserPlantModel plant) async {
    await _plantsRef(userId).doc(plant.id).set(plant.toMap());
  }

  Future<void> deletePlant(String userId, String plantId) async {
    await _plantsRef(userId).doc(plantId).delete();
  }

  Future<void> updateNextWatering(String userId, String plantId, DateTime date) async {
    await _plantsRef(userId).doc(plantId).update({'nextWatering': Timestamp.fromDate(date)});
  }

  Future<void> waterPlant(String userId, String plantId, String wateringType) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final userRef = _db.collection('users').doc(userId);
    final userDoc = await userRef.get();
    final data = userDoc.data() ?? {};

    final lastTs = data['lastWateredDate'] as Timestamp?;
    final lastDay = lastTs != null
        ? DateTime(lastTs.toDate().year, lastTs.toDate().month, lastTs.toDate().day)
        : null;

    final alreadyToday = lastDay != null && lastDay == today;
    int currentStreak = data['streak'] ?? 0;

    final Map<String, dynamic> userUpdate = {
      'totalWaterings': FieldValue.increment(1),
    };

    if (!alreadyToday) {
      currentStreak = (lastDay == yesterday) ? currentStreak + 1 : 1;
      userUpdate['streak'] = currentStreak;
      userUpdate['lastWateredDate'] = Timestamp.fromDate(now);
    }

    final batch = _db.batch();
    batch.update(_plantsRef(userId).doc(plantId), {
      'lastWatered': Timestamp.fromDate(now),
      'nextWatering': Timestamp.fromDate(calculateNextWatering(wateringType)),
    });
    batch.set(userRef, userUpdate, SetOptions(merge: true));
    await batch.commit();
  }
}
