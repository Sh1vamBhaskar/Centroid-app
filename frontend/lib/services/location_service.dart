import 'package:geolocator/geolocator.dart';

import 'api_service.dart';

class LocationService {
  static Future<bool> updateCurrentLocation() async {
    // Check whether location services are enabled.
    final serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return false;
    }

    // Check current permission.
    LocationPermission permission =
    await Geolocator.checkPermission();

    // Ask the user for permission if needed.
    if (permission == LocationPermission.denied) {
      permission =
      await Geolocator.requestPermission();
    }

    // User denied the permission.
    if (permission == LocationPermission.denied) {
      return false;
    }

    // User permanently denied the permission.
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // Get the current GPS position.
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    // Send the coordinates to our Spring Boot backend.
    await ApiService.updateLocation(
      position.latitude,
      position.longitude,
    );

    return true;
  }
}