import 'package:geolocator/geolocator.dart';

/// Encapsula la obtencion de la ubicacion del dispositivo con manejo de
/// permisos. Nunca lanza excepciones: si algo falla (sin permiso, servicio
/// desactivado, timeout) devuelve null y la app continua sin ubicacion,
/// de modo que el riego usara el intervalo base de Perenual sin ajuste.
class LocationService {
  Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low, // suficiente para el clima
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      return null;
    }
  }
}
