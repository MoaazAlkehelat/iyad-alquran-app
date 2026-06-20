import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/khatma_model.dart';

class KhatmaService {

  static Future<void> saveKhatma(
      KhatmaModel khatma) async {

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      'khatma',
      jsonEncode(khatma.toMap()),
    );
  }

  static Future<KhatmaModel?>
  getKhatma() async {

    final prefs =
    await SharedPreferences.getInstance();

    final data =
    prefs.getString('khatma');

    if (data == null) return null;

    return KhatmaModel.fromMap(
      jsonDecode(data),
    );
  }

  static Future<void> clearKhatma() async {

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.remove('khatma');
  }

  static int getTodayStartPage(
      KhatmaModel khatma) {

    final daysPassed =
        DateTime.now()
            .difference(khatma.startDate)
            .inDays;

    return khatma.startPage +
        (daysPassed * khatma.dailyPages);
  }

  static int getTodayEndPage(
      KhatmaModel khatma) {

    return getTodayStartPage(khatma)
        + khatma.dailyPages - 1;
  }

  static double getProgress(
      KhatmaModel khatma) {

    return khatma.currentPage / 604;
  }
}