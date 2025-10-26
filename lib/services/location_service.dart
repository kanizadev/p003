import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:math';

class LocationService {
  static Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceException(
          'Location services are disabled. Please enable location services.',
        );
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationServiceException(
            'Location permissions are denied. Please grant location permission to get weather data.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationServiceException(
          'Location permissions are permanently denied. Please enable location permission in app settings.',
        );
      }

      // Get current position with high accuracy
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      if (e is LocationServiceException) {
        rethrow;
      }
      throw LocationServiceException(
        'Failed to get current location: ${e.toString()}',
      );
    }
  }

  static Future<String> getCityNameFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        // Try to get city name, fallback to locality, then administrative area
        return placemark.locality ??
            placemark.administrativeArea ??
            placemark.subAdministrativeArea ??
            'Unknown City';
      }

      return 'Unknown City';
    } catch (e) {
      return 'Unknown City';
    }
  }

  static Future<List<Placemark>> searchLocation(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      List<Location> locations = await locationFromAddress(query);
      List<Placemark> placemarks = [];

      for (Location location in locations) {
        List<Placemark> marks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );
        placemarks.addAll(marks);
      }

      return placemarks;
    } catch (e) {
      return [];
    }
  }

  static Future<bool> requestLocationPermission() async {
    try {
      var status = await Permission.location.status;

      if (status.isDenied) {
        status = await Permission.location.request();
      }

      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isLocationPermissionGranted() async {
    try {
      var status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      return false;
    }
  }

  static Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      // Handle error silently
    }
  }

  static Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      // Handle error silently
    }
  }

  // Advanced location features
  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  static Future<double> calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) async {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  static Future<List<Placemark>> getNearbyCities(
    double latitude,
    double longitude, {
    double radiusKm = 50,
  }) async {
    try {
      // Generate points around the current location
      List<Placemark> nearbyCities = [];

      for (int i = 0; i < 8; i++) {
        double angle = i * (2 * pi / 8);
        double newLat = latitude + (radiusKm / 111) * cos(angle);
        double newLon = longitude + (radiusKm / 111) * sin(angle);

        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            newLat,
            newLon,
          );
          if (placemarks.isNotEmpty) {
            nearbyCities.add(placemarks.first);
          }
        } catch (e) {
          // Continue with next point
        }
      }

      return nearbyCities;
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getLocationInfo(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return {
          'city': placemark.locality ?? 'Unknown',
          'state': placemark.administrativeArea ?? 'Unknown',
          'country': placemark.country ?? 'Unknown',
          'postalCode': placemark.postalCode ?? 'Unknown',
          'address': _formatAddress(placemark),
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'timestamp': position.timestamp,
        };
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  static String _formatAddress(Placemark placemark) {
    List<String> addressParts = [];

    if (placemark.street != null && placemark.street!.isNotEmpty) {
      addressParts.add(placemark.street!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      addressParts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null &&
        placemark.administrativeArea!.isNotEmpty) {
      addressParts.add(placemark.administrativeArea!);
    }
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      addressParts.add(placemark.country!);
    }

    return addressParts.join(', ');
  }

  static Future<bool> isLocationAccurate(Position position) async {
    return position.accuracy <= 100; // Within 100 meters
  }

  static Future<Map<String, dynamic>> getLocationHistory() async {
    // This would typically be stored in a database
    // For now, return a mock implementation
    return {
      'recentLocations': [],
      'favoriteLocations': [],
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  static Future<void> saveLocationToHistory(Placemark placemark) async {
    // This would typically save to a local database
    // For now, just a placeholder
  }

  static Future<List<Placemark>> getFavoriteLocations() async {
    // This would typically retrieve from a local database
    // For now, return some default locations
    return [
      Placemark(
        locality: 'Dhaka',
        administrativeArea: 'Dhaka',
        country: 'Bangladesh',
      ),
      Placemark(
        locality: 'New York',
        administrativeArea: 'New York',
        country: 'United States',
      ),
    ];
  }
}

class LocationServiceException implements Exception {
  final String message;
  LocationServiceException(this.message);

  @override
  String toString() => 'LocationServiceException: $message';
}
