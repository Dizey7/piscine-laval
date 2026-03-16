import 'package:geolocator/geolocator.dart';
import '../utils/constants.dart';

/// Service de géolocalisation
class LocationService {
  Position? _lastPosition;

  Position? get lastPosition => _lastPosition;

  /// Vérifie et demande les permissions de localisation
  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  /// Position actuelle de l'utilisateur
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;

    try {
      _lastPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return _lastPosition;
    } catch (e) {
      return _lastPosition; // Fallback sur la dernière position connue
    }
  }

  /// Distance entre la position de l'utilisateur et un point
  double? distanceToKm(double lat, double lng) {
    if (_lastPosition == null) return null;
    final meters = Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      lat,
      lng,
    );
    return meters / 1000;
  }

  /// Position par défaut (centre de Montréal) si pas de permission
  static Position get defaultMontreal => Position(
        latitude: AppConstants.mtlLatitude,
        longitude: AppConstants.mtlLongitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
}
