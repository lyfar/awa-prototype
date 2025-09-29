import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

/// Service to manage user's daily practice state and location
class PracticeService {
  static const String _practiceKey = 'practiced_today';
  static const String _lastPracticeDateKey = 'last_practice_date';
  static const String _userLatKey = 'user_latitude';
  static const String _userLngKey = 'user_longitude';
  
  /// Check if user has practiced today
  static Future<bool> hasPracticedToday() async {
    print('PracticeService: Checking if user practiced today');
    final prefs = await SharedPreferences.getInstance();
    
    final lastPracticeDate = prefs.getString(_lastPracticeDateKey);
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    final practiced = lastPracticeDate == today;
    print('PracticeService: User practiced today: $practiced');
    return practiced;
  }
  
  /// Mark that user completed practice today
  static Future<void> markPracticeCompleted() async {
    print('PracticeService: Marking practice as completed for today');
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    await prefs.setBool(_practiceKey, true);
    await prefs.setString(_lastPracticeDateKey, today);
    
    print('PracticeService: Practice completed and saved');
  }
  
  /// Get user's saved location
  static Future<Map<String, double?>> getUserLocation() async {
    print('PracticeService: Getting user location');
    final prefs = await SharedPreferences.getInstance();
    
    final latitude = prefs.getDouble(_userLatKey);
    final longitude = prefs.getDouble(_userLngKey);
    
    print('PracticeService: User location - lat: $latitude, lng: $longitude');
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
  
  /// Save user's current location
  static Future<void> saveCurrentLocation() async {
    print('PracticeService: Attempting to save current location');
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_userLatKey, position.latitude);
      await prefs.setDouble(_userLngKey, position.longitude);
      
      print('PracticeService: Location saved - lat: ${position.latitude}, lng: ${position.longitude}');
    } catch (e) {
      print('PracticeService: Failed to get location: $e');
    }
  }
  
  /// Get practice streak count
  static Future<int> getPracticeStreak() async {
    // This would calculate consecutive days of practice
    // For now, return a mock value
    return 7;
  }
  
  /// Reset practice data (for testing)
  static Future<void> resetPracticeData() async {
    print('PracticeService: Resetting practice data');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_practiceKey);
    await prefs.remove(_lastPracticeDateKey);
    print('PracticeService: Practice data reset');
  }
}
