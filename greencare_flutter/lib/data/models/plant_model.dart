class PlantModel {
  final int id;
  final String commonName;
  final String scientificName;
  final String? imageUrl;
  final String? watering;    // "Frequent", "Average", "Minimum"
  final List<String>? sunlight;
  final String? cycle;

  PlantModel({
    required this.id,
    required this.commonName,
    required this.scientificName,
    this.imageUrl,
    this.watering,
    this.sunlight,
    this.cycle,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'],
      commonName: json['common_name'] ?? 'Sin nombre',
      scientificName: (json['scientific_name'] as List?)?.first ?? '',
      imageUrl: json['default_image']?['medium_url'],
      watering: json['watering'],
      sunlight: (json['sunlight'] as List?)?.cast<String>(),
      cycle: json['cycle'],
    );
  }
}