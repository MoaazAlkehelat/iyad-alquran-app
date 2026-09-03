import 'package:flutter_test/flutter_test.dart';
import 'package:iyad_alquran/data/models/khatma_model.dart';
import 'package:iyad_alquran/data/services/khatma_service.dart';

KhatmaModel _khatma({
  required int dailyPages,
  required int currentPage,
  required int startedDaysAgo,
  DateTime? targetDate,
}) {
  return KhatmaModel(
    dailyPages: dailyPages,
    startPage: 1,
    currentPage: currentPage,
    startDate: DateTime.now().subtract(Duration(days: startedDaysAgo)),
    completed: false,
    targetDate: targetDate,
  );
}

void main() {
  test("today's assignment tracks days elapsed", () {
    final k = _khatma(dailyPages: 4, currentPage: 20, startedDaysAgo: 10);
    expect(KhatmaService.getTodayStartPage(k), 41);
    expect(KhatmaService.getTodayEndPage(k), 44);
  });

  test('remaining pages and days', () {
    final k = _khatma(dailyPages: 4, currentPage: 20, startedDaysAgo: 10);
    expect(KhatmaService.getRemainingPages(k), 584);
    expect(KhatmaService.getRemainingDays(k), 146); // ceil(584 / 4)
  });

  test('pace: behind / on-track / ahead', () {
    expect(
      KhatmaService.getPace(
          _khatma(dailyPages: 4, currentPage: 20, startedDaysAgo: 10)),
      KhatmaPace.behind,
    );
    expect(
      KhatmaService.getPace(
          _khatma(dailyPages: 4, currentPage: 44, startedDaysAgo: 10)),
      KhatmaPace.onTrack,
    );
    expect(
      KhatmaService.getPace(
          _khatma(dailyPages: 4, currentPage: 60, startedDaysAgo: 10)),
      KhatmaPace.ahead,
    );
  });

  test('estimated finish date is remainingDays out', () {
    final k = _khatma(dailyPages: 10, currentPage: 104, startedDaysAgo: 10);
    final days = KhatmaService.getRemainingDays(k); // ceil(500/10) = 50
    final eta = KhatmaService.getEstimatedFinishDate(k);
    final now = DateTime.now();
    expect(eta.difference(DateTime(now.year, now.month, now.day)).inDays, days);
  });

  test('pages/day for a target date', () {
    final k = _khatma(
      dailyPages: 4,
      currentPage: 20,
      startedDaysAgo: 10,
      targetDate: DateTime.now().add(const Duration(days: 10)),
    );
    // 584 remaining / 10 days -> ceil(58.4) = 59
    expect(KhatmaService.getPagesPerDayForTarget(k), 59);
  });

  test('progress is a 0..1 fraction of 604', () {
    final k = _khatma(dailyPages: 4, currentPage: 302, startedDaysAgo: 1);
    expect(KhatmaService.getProgress(k), closeTo(0.5, 0.01));
  });
}
