/// Datos meteorologicos relevantes para el calculo de riego.
/// Vive en core/ para no introducir dependencias hacia data/.
class WeatherData {
  final double maxTemp; // ºC maxima prevista hoy
  final double minTemp; // ºC minima prevista hoy
  final double humidity; // % humedad relativa actual
  final double precipitationMm; // mm de lluvia previstos hoy

  const WeatherData({
    required this.maxTemp,
    required this.minTemp,
    required this.humidity,
    required this.precipitationMm,
  });
}

/// Intervalo base en dias segun el tipo de riego de Perenual.
int baseWateringDays(String wateringType) {
  switch (wateringType) {
    case 'Frequent':
      return 2;
    case 'Average':
      return 5;
    case 'Minimum':
      return 10;
    default:
      return 30;
  }
}

/// Calcula la proxima fecha de riego.
/// Si se pasa [weather], ajusta el intervalo segun el tiempo de la ubicacion
/// de la planta. Si es null (sin ubicacion o el servicio fallo), usa el
/// intervalo base de Perenual sin cambios.
DateTime calculateNextWatering(
  String wateringType, {
  WeatherData? weather,
  DateTime? from,
}) {
  final base = baseWateringDays(wateringType);
  final days = weather == null ? base : _weatherAdjustedDays(base, weather);
  final start = from ?? DateTime.now().toLocal();
  return DateTime(start.year, start.month, start.day).add(Duration(days: days));
}

/// Aplica un factor multiplicador al intervalo base segun las condiciones.
/// Calor/sequedad acortan el intervalo (regar antes); frio/humedad/lluvia
/// lo alargan. El factor se limita a [0.5, 1.6] y el resultado a [1, 60] dias.
int _weatherAdjustedDays(int baseDays, WeatherData w) {
  double factor = 1.0;
  if (w.maxTemp > 28) factor -= 0.20; // calor -> regar antes
  if (w.humidity < 40) factor -= 0.15; // aire seco -> regar antes
  if (w.maxTemp < 12) factor += 0.25; // frio -> espaciar
  if (w.humidity > 75) factor += 0.15; // ambiente humedo -> espaciar
  if (w.precipitationMm > 5)
    factor += 0.30; // lluvia (balcon/exterior) -> espaciar
  factor = factor.clamp(0.5, 1.6);
  final adjusted = (baseDays * factor).round();
  return adjusted.clamp(1, 60);
}
