import 'package:shared_preferences/shared_preferences.dart';

class AppStateService {

  static const usernameKey =
      'username';

  static const lastPageKey =
      'last_page';

  static const darkModeKey =
      'dark_mode';

  // USERNAME

  static Future<void>
  saveUsername(
      String name,
      ) async {

    final prefs =
    await SharedPreferences
        .getInstance();

    await prefs.setString(
      usernameKey,
      name,
    );
  }

  static Future<String?>
  getUsername() async {

    final prefs =
    await SharedPreferences
        .getInstance();

    return prefs.getString(
      usernameKey,
    );
  }

  // LAST PAGE

  static Future<void>
  saveLastPage(
      int page,
      ) async {

    final prefs =
    await SharedPreferences
        .getInstance();

    await prefs.setInt(
      lastPageKey,
      page,
    );
  }

  static Future<int>
  getLastPage() async {

    final prefs =
    await SharedPreferences
        .getInstance();

    return prefs.getInt(
      lastPageKey,
    ) ??
        0;
  }

  // DARK MODE

  static Future<void>
  saveDarkMode(
      bool value,
      ) async {

    final prefs =
    await SharedPreferences
        .getInstance();

    await prefs.setBool(
      darkModeKey,
      value,
    );
  }

  static Future<bool>
  getDarkMode() async {

    final prefs =
    await SharedPreferences
        .getInstance();

    return prefs.getBool(
      darkModeKey,
    ) ??
        false;
  }
}