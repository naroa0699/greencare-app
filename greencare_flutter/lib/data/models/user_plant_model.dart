import 'package:cloud_firestore/cloud_firestore.dart';

class UserPlantModel {
  final String id;
  final String commonName;
  final String? nickname;
  final String? imageUrl;
  final String watering;
  final DateTime addedAt;
  final DateTime nextWatering;

  UserPlantModel({
    required this.id,
    required this.commonName,
    this.nickname,
    this.imageUrl,
    required this.watering,
    required this.addedAt,
    required this.nextWatering,
  });

  factory UserPlantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserPlantModel(
      id: doc.id,
      commonName: data['commonName'] ?? '',
      nickname: data['nickname'],
      imageUrl: data['imageUrl'],
      watering: data['watering'] ?? 'Average',
      addedAt: (data['addedAt'] as Timestamp).toDate(),
      nextWatering: (data['nextWatering'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commonName': commonName,
      'nickname': nickname,
      'imageUrl': imageUrl,
      'watering': watering,
      'addedAt': Timestamp.fromDate(addedAt),
      'nextWatering': Timestamp.fromDate(nextWatering),
    };
  }
}