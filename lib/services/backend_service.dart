import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BackendService {
  static const String _baseUrl = 'https://api.mindfulnessapp.com'; // Replace with your actual API

  static Future<void> loadAppData() async {
    try {
      // Simulate loading app configuration, user preferences, etc.
      final prefs = await SharedPreferences.getInstance();

      // Load cached data or fetch from API
      final response = await http.get(
        Uri.parse('$_baseUrl/config'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Cache the data
        await prefs.setString('app_config', json.encode(data));
      }

      // Load user preferences if logged in
      // This is just a placeholder for actual backend integration

    } catch (e) {
      // Handle network errors gracefully
      print('Error loading app data: $e');
      // Continue with cached data if available
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error getting user profile: $e');
    }
    return null;
  }

  static Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId != null) {
        await http.put(
          Uri.parse('$_baseUrl/users/$userId/preferences'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(preferences),
        );
      }

      // Cache locally
      await prefs.setString('user_preferences', json.encode(preferences));
    } catch (e) {
      print('Error updating user preferences: $e');
    }
  }
}
