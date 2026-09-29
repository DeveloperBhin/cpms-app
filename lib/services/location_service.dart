import 'package:geolocator/geolocator.dart';

class LocationResult {
  final String geometry;
  final double speed; // meters/second
  final double accuracy; // meters

  LocationResult({
    required this.geometry,
    required this.speed,
    required this.accuracy,
  });
}

class LocationService {
  /// Throws a String error message on failure/denial.
  static Future<LocationResult> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled. Please enable GPS.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permission was denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permission is permanently denied. Enable it in app settings.';
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    return LocationResult(
      geometry: 'POINT(${position.longitude} ${position.latitude})',
      speed: position.speed,
      accuracy: position.accuracy,
    );
  }
}
