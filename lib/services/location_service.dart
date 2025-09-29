import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'backend_service.dart';

class LocationService {
  static const String _baseUrl =
      'https://api.mindfulnessapp.com'; // Replace with your actual API

  static Future<bool> checkLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  static Future<void> saveUserLocation(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save locally first
      final locationData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': position.timestamp.toIso8601String(),
        'accuracy': position.accuracy,
      };

      await prefs.setString('last_location', json.encode(locationData));

      // Send to backend
      final userId = prefs.getString('user_id');
      if (userId != null) {
        await http.post(
          Uri.parse('$_baseUrl/users/$userId/location'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'accuracy': position.accuracy,
          }),
        );
      }
    } catch (e) {
      print('Error saving user location: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> findNearbyUsers({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/users/nearby?lat=$latitude&lng=$longitude&radius=$radiusKm',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['users'] ?? []);
      }
    } catch (e) {
      print('Error finding nearby users: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getLocationFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // Using a geocoding service - you might want to use Google Maps API or similar
      final response = await http.get(
        Uri.parse(
          'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$latitude&longitude=$longitude&localityLanguage=en',
        ),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error getting location from coordinates: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationString = prefs.getString('last_location');

      if (locationString != null) {
        return json.decode(locationString);
      }
    } catch (e) {
      print('Error getting cached location: $e');
    }
    return null;
  }
}
