import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight profile storage for onboarding data capture.
/// Persists user display name locally so subsequent sessions can
/// restore the welcome flow context and personalise copy.
class UserProfileService {
  static const String _displayNameKey = 'user_display_name';

  /// Persist the user's preferred display name locally.
  static Future<void> saveDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_displayNameKey, name.trim());
  }

  /// Retrieve the stored display name if available.
  static Future<String?> getDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString(_displayNameKey);
    if (storedName == null || storedName.trim().isEmpty) {
      return null;
    }
    return storedName.trim();
  }
}
