import 'package:shared_preferences/shared_preferences.dart';

/// Small persisted bits that aren't part of [AppSettings]:
/// the user's name and the last mushaf page they were on (1-based).
class AppStateService {
  static const usernameKey = 'username';
  static const lastPageKey = 'last_page';

  static Future<void> saveUsername(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(usernameKey, name);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(usernameKey);
  }

  /// [page] is a 1-based mushaf page number.
  static Future<void> saveLastPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(lastPageKey, page);
  }

  /// Returns a 1-based mushaf page number (defaults to 1).
  static Future<int> getLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(lastPageKey) ?? 1;
    return v < 1 ? 1 : v;
  }
}
