import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _tokenKey = 'token';

  static Future<String?> getToken() async {
    final prefs =
        await SharedPreferences.getInstance();

    final token = prefs.getString(_tokenKey);

    if (token == null || token.trim().isEmpty) {
      return null;
    }

    return token.trim();
  }

  static Future<void> saveToken(
    String token,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _tokenKey,
      token.trim(),
    );
  }

  static Future<bool> hasSession() async {
    final token = await getToken();

    return token != null && token.isNotEmpty;
  }

  static Future<void> clearSession() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
  }
}