import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_plant_model.dart';

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

}