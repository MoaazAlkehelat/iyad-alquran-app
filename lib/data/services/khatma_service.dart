import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/quran_constants.dart';
import '../models/khatma_model.dart';

enum KhatmaPace { ahead, onTrack, behind }

class KhatmaService {
  static const _key = 'khatma';

  static Future<void> saveKhatma(KhatmaModel khatma) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(khatma.toMap()));
  }

  static Future<KhatmaModel?> getKhatma() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return null;
    return KhatmaModel.fromMap(jsonDecode(data) as Map<String, dynamic>);
  }

  static Future<void> clearKhatma() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static int _daysPassed(KhatmaModel k) {
    final start = DateTime(k.startDate.year, k.startDate.month, k.startDate.day);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).difference(start).inDays;
  }

  /// First page of today's assignment.
  static int getTodayStartPage(KhatmaModel k) {
    final page = k.startPage + (_daysPassed(k) * k.dailyPages);
    return page.clamp(1, kQuranPageCount);
  }

  /// Last page of today's assignment.
  static int getTodayEndPage(KhatmaModel k) {
    final page = getTodayStartPage(k) + k.dailyPages - 1;
    return page.clamp(1, kQuranPageCount);
  }

  /// 0.0 – 1.0 overall completion.
  static double getProgress(KhatmaModel k) =>
      (k.currentPage / kQuranPageCount).clamp(0.0, 1.0);

  static int getRemainingPages(KhatmaModel k) =>
      (kQuranPageCount - k.currentPage).clamp(0, kQuranPageCount);

  /// The page the reader is expected to have reached by the end of today.
  static int getExpectedPageForToday(KhatmaModel k) =>
      (k.startPage + ((_daysPassed(k) + 1) * k.dailyPages) - 1)
          .clamp(1, kQuranPageCount);

  static KhatmaPace getPace(KhatmaModel k) {
    final expected = getExpectedPageForToday(k);
    if (k.currentPage >= expected + k.dailyPages) return KhatmaPace.ahead;
    if (k.currentPage >= expected - k.dailyPages) return KhatmaPace.onTrack;
    return KhatmaPace.behind;
  }

  /// Days left at the user's chosen daily pace.
  static int getRemainingDays(KhatmaModel k) {
    final remaining = getRemainingPages(k);
    if (remaining == 0 || k.dailyPages <= 0) return 0;
    return (remaining / k.dailyPages).ceil();
  }

  static DateTime getEstimatedFinishDate(KhatmaModel k) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day)
        .add(Duration(days: getRemainingDays(k)));
  }

  /// Pages/day needed to finish by [KhatmaModel.targetDate]; null if no target.
  static int? getPagesPerDayForTarget(KhatmaModel k) {
    final target = k.targetDate;
    if (target == null) return null;
    final now = DateTime.now();
    final days = DateTime(target.year, target.month, target.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    if (days <= 0) return getRemainingPages(k);
    return (getRemainingPages(k) / days).ceil();
  }
}
