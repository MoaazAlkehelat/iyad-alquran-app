import 'package:flutter_test/flutter_test.dart';
import 'package:iyad_alquran/core/constants/quran_constants.dart';
import 'package:iyad_alquran/core/utils/arabic.dart';
import 'package:iyad_alquran/features/quran/data/quran_repository.dart';

void main() {
  final repo = QuranRepository.instance;

  test('has 604 pages', () {
    expect(repo.pageCount, kQuranPageCount);
  });

  test('page 1 is Al-Fatiha, basmala is ayah 1 (no separate basmala widget)', () {
    final page = repo.pageContent(1);
    expect(page.juz, 1);
    expect(page.blocks.length, 1);
    final b = page.blocks.first;
    expect(b.surahNumber, 1);
    expect(b.isSurahStart, isTrue);
    expect(b.showBasmala, isFalse); // surah 1: basmala IS ayah 1
    expect(b.ayat.first.ayah, 1);
  });

  test('the basmala prefix is stripped from verse 1 (except Al-Fatiha)', () {
    String v1(int surah) => normalizeArabic(repo
        .pageContent(repo.pageForSurah(surah))
        .blocks
        .firstWhere((b) => b.surahNumber == surah)
        .ayat
        .first
        .text);

    const basmala = 'بسم الله الرحمن الرحيم';
    // Al-Fatiha keeps it — it IS ayah 1.
    expect(v1(1), basmala);
    // Al-Baqarah 1 becomes just the letters.
    expect(v1(2), 'الم');
    // Al-Ikhlas 1 drops the basmala, keeps its own words.
    expect(v1(112).startsWith(basmala), isFalse);
    expect(v1(112).startsWith('قل هو الله احد'), isTrue);
    // At-Tawbah is unaffected (never had a basmala).
    expect(v1(9).startsWith(basmala), isFalse);
    expect(v1(9).startsWith('براه'), isTrue); // normalizeArabic drops the hamza
  });

  test('surah names carry harakat', () {
    expect(repo.surahNameAr(1), 'الفَاتِحَة');
    expect(repo.surahNameAr(113), 'الفَلَق');
    expect(repo.surahNameAr(114), 'النَّاس');
  });

  test('page 187 starts At-Tawbah with no basmala', () {
    final page = repo.pageContent(187);
    final tawbah = page.blocks.firstWhere((b) => b.surahNumber == 9);
    expect(tawbah.isSurahStart, isTrue);
    expect(tawbah.showBasmala, isFalse);
  });

  test('a mid-page surah start shows a header + basmala (An-Nisa, page 77)', () {
    final page = repo.pageContent(77);
    final nisa = page.blocks.firstWhere((b) => b.surahNumber == 4);
    expect(nisa.isSurahStart, isTrue);
    expect(nisa.showBasmala, isTrue);
  });

  test('juz is 1 at the start, 30 at the end, and never decreases', () {
    expect(repo.juzForPage(1), 1);
    expect(repo.juzForPage(kQuranPageCount), 30);
    var prev = 1;
    for (var p = 1; p <= kQuranPageCount; p++) {
      final j = repo.juzForPage(p);
      expect(j, greaterThanOrEqualTo(prev), reason: 'page $p');
      expect(j, inInclusiveRange(1, 30));
      prev = j;
    }
  });

  test('pageForSurah matches quran mapping', () {
    expect(repo.pageForSurah(1), 1);
    expect(repo.pageForSurah(2), 2);
    expect(repo.pageForSurah(9), 187);
    expect(repo.pageForSurah(114), 604);
  });

  test('allAyat yields the full mushaf', () {
    expect(repo.allAyat().length, kQuranVerseCount);
  });

  test('ayah search finds Al-Fatiha 2 with its page', () {
    final hits = repo.search('الحمد لله رب العالمين');
    expect(hits, isNotEmpty);
    final fatiha = hits.firstWhere((h) => h.surah == 1);
    expect(fatiha.ayah, 2);
    expect(fatiha.page, 1);
  });

  test('every page builds without throwing', () {
    for (var p = 1; p <= kQuranPageCount; p++) {
      expect(() => repo.pageContent(p), returnsNormally, reason: 'page $p');
    }
  });
}
