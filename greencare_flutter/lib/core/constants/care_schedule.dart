DateTime calculateNextWatering(String wateringType) {
  final now = DateTime.now();
  switch (wateringType) {
    case 'Frequent':
      return now.add(const Duration(days: 2));
    case 'Average':
      return now.add(const Duration(days: 5));
    case 'Minimum':
      return now.add(const Duration(days: 10));
    default:
      return now.add(const Duration(days: 30));
  }
}