import 'package:cloud_firestore/cloud_firestore.dart';

class UserPlantModel {
  final String id;
  final String commonName;
  final String? nickname;
  final String? imageUrl; // imagen del catalogo (Perenual / Wikimedia)
  final String? photoUrl; // foto propia del usuario (Firebase Storage)
  final String watering;
  final String? sunlight; // requerimiento de luz
  final String? humidity; // preferencia de humedad
  final DateTime addedAt;
  final DateTime nextWatering;
  final DateTime? lastWatered;
  final DateTime? lastFertilized;
  final DateTime? nextFertilizing;
  final DateTime? lastTransplanted;
  final double? latitude; // ubicacion de la planta (para el clima)
  final double? longitude;

  UserPlantModel({
    required this.id,
    required this.commonName,
    this.nickname,
    this.imageUrl,
    this.photoUrl,
    required this.watering,
    this.sunlight,
    this.humidity,
    required this.addedAt,
    required this.nextWatering,
    this.lastWatered,
    this.lastFertilized,
    this.nextFertilizing,
    this.lastTransplanted,
    this.latitude,
    this.longitude,
  });

  factory UserPlantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime? ts(String key) =>
        data[key] != null ? (data[key] as Timestamp).toDate() : null;

    return UserPlantModel(
      id: doc.id,
      commonName: data['commonName'] ?? '',
      nickname: data['nickname'],
      imageUrl: data['imageUrl'],
      photoUrl: data['photoUrl'],
      watering: data['watering'] ?? 'Average',
      sunlight: data['sunlight'],
      humidity: data['humidity'],
      addedAt: (data['addedAt'] as Timestamp).toDate(),
      nextWatering: (data['nextWatering'] as Timestamp).toDate(),
      lastWatered: ts('lastWatered'),
      lastFertilized: ts('lastFertilized'),
      nextFertilizing: ts('nextFertilizing'),
      lastTransplanted: ts('lastTransplanted'),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'commonName': commonName,
    'nickname': nickname,
    'imageUrl': imageUrl,
    if (photoUrl != null) 'photoUrl': photoUrl,
    'watering': watering,
    if (sunlight != null) 'sunlight': sunlight,
    if (humidity != null) 'humidity': humidity,
    'addedAt': Timestamp.fromDate(addedAt),
    'nextWatering': Timestamp.fromDate(nextWatering),
    if (lastWatered != null) 'lastWatered': Timestamp.fromDate(lastWatered!),
    if (lastFertilized != null)
      'lastFertilized': Timestamp.fromDate(lastFertilized!),
    if (nextFertilizing != null)
      'nextFertilizing': Timestamp.fromDate(nextFertilizing!),
    if (lastTransplanted != null)
      'lastTransplanted': Timestamp.fromDate(lastTransplanted!),
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
  };

  UserPlantModel copyWith({
    String? nickname,
    String? imageUrl,
    String? photoUrl,
    String? watering,
    String? sunlight,
    String? humidity,
    DateTime? nextWatering,
    DateTime? lastWatered,
    DateTime? lastFertilized,
    DateTime? nextFertilizing,
    DateTime? lastTransplanted,
    double? latitude,
    double? longitude,
  }) {
    return UserPlantModel(
      id: id,
      commonName: commonName,
      nickname: nickname ?? this.nickname,
      imageUrl: imageUrl ?? this.imageUrl,
      photoUrl: photoUrl ?? this.photoUrl,
      watering: watering ?? this.watering,
      sunlight: sunlight ?? this.sunlight,
      humidity: humidity ?? this.humidity,
      addedAt: addedAt,
      nextWatering: nextWatering ?? this.nextWatering,
      lastWatered: lastWatered ?? this.lastWatered,
      lastFertilized: lastFertilized ?? this.lastFertilized,
      nextFertilizing: nextFertilizing ?? this.nextFertilizing,
      lastTransplanted: lastTransplanted ?? this.lastTransplanted,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
