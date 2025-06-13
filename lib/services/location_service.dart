import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static const double universityLatitude = 14.6928; // Coordonnées approximatives pour MGRR+6HW
  static const double universityLongitude = -17.4467; // Av. Cheikh Anta Diop, Dakar

  // Demander les permissions de localisation
  static Future<bool> requestLocationPermission() async {
    try {
      // Vérifier si les services de localisation sont activés
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      print('Erreur lors de la demande de permission: $e');
      return false;
    }
  }

  // Obtenir la position actuelle
  static Future<Position?> getCurrentPosition() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print('Erreur lors de l\'obtention de la position: $e');
      return null;
    }
  }

  // Calculer la distance entre deux points
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Calculer la distance jusqu'à l'université
  static double calculateDistanceToUniversity(double latitude, double longitude) {
    return calculateDistance(
      latitude,
      longitude,
      universityLatitude,
      universityLongitude,
    );
  }

  // Vérifier si l'utilisateur est proche de l'université (dans un rayon de 500m)
  static bool isNearUniversity(double latitude, double longitude) {
    double distance = calculateDistanceToUniversity(latitude, longitude);
    return distance <= 500; // 500 mètres
  }

  // Écouter les changements de position
  static Stream<Position> getPositionStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Mise à jour tous les 10 mètres
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}