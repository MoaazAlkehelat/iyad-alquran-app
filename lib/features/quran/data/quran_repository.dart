import 'package:quran/quran.dart' as quran;

import '../../../core/constants/quran_constants.dart';
import '../../../core/utils/arabic.dart';
import 'surah_names_ar.dart';

/// The Tanzil "simple" text prepends the basmala (its first four words) to
/// verse 1 of every surah except At-Tawbah. We render our own standalone
/// basmala, so it's stripped from the ayah text — matched diacritic-insensitively.
final String _normBasmala = normalizeArabic(quran.basmala);

String _verseText(int surah, int verse) {
  final t = quran.getVerse(surah, verse);
  if (verse == 1 && surah != 1 && normalizeArabic(t).startsWith(_normBasmala)) {
    final parts = t.trim().split(RegExp(r'\s+'));
    if (parts.length > 4) return parts.sublist(4).join(' ');
  }
  return t;
}

/// A single ayah as an addressable entity. Powers both the reader and search.
class AyahEntity {
  final int surah;
  final int ayah;
  final String text;
  final int page;
  final int juz;
  final bool isSajda;

  const AyahEntity({
    required this.surah,
    required this.ayah,
    required this.text,
    required this.page,
    required this.juz,
    required this.isSajda,
  });
}

/// A run of consecutive ayat from one surah that appear on a single page.
class SurahBlock {
  final int surahNumber;
  final String surahNameAr;
  final String revelation; // "Makkah" | "Madinah"
  final int totalVerses;
  final bool isSurahStart;
  final bool showBasmala;
  final List<AyahEntity> ayat;

  const SurahBlock({
    required this.surahNumber,
    required this.surahNameAr,
    required this.revelation,
    required this.totalVerses,
    required this.isSurahStart,
    required this.showBasmala,
    required this.ayat,
  });
}

/// The rendered content of one mushaf page.
class PageContent {
  final int pageNumber;
  final int juz;
  final List<SurahBlock> blocks;

  const PageContent({
    required this.pageNumber,
    required this.juz,
    required this.blocks,
  });
}

class AyahSearchHit {
  final int surah;
  final String surahNameAr;
  final int ayah;
  final int page;
  final int juz;
  final String text;

  const AyahSearchHit({
    required this.surah,
    required this.surahNameAr,
    required this.ayah,
    required this.page,
    required this.juz,
    required this.text,
  });
}

/// Thin, cached, fully-offline wrapper over the `quran` package.
class QuranRepository {
  QuranRepository._();
  static final QuranRepository instance = QuranRepository._();

  final Map<int, PageContent> _pageCache = {};
  List<AyahEntity>? _allAyat;
  List<String>? _normalizedAyat;

  static const String basmala = quran.basmala;

  int get pageCount => quran.totalPagesCount; // 604

  String surahNameAr(int surahNumber) =>
      kSurahNamesAr[surahNumber] ?? quran.getSurahNameArabic(surahNumber);

  bool isMakkah(int surahNumber) =>
      quran.getPlaceOfRevelation(surahNumber).toLowerCase().startsWith('makk');

  int pageForSurah(int surahNumber) => quran.getPageNumber(surahNumber, 1);

  int pageForAyah(int surahNumber, int ayahNumber) =>
      quran.getPageNumber(surahNumber, ayahNumber);

  int juzForPage(int page) => pageContent(page).juz;

  PageContent pageContent(int page) {
    final cached = _pageCache[page];
    if (cached != null) return cached;

    final raw = quran.getPageData(page); // [{surah, start, end}, ...]
    final blocks = <SurahBlock>[];

    for (final e in raw) {
      final int surahNumber = e['surah'] as int;
      final int start = e['start'] as int;
      final int end = e['end'] as int;
      final bool isSurahStart = start == 1;

      final ayat = <AyahEntity>[
        for (int v = start; v <= end; v++)
          AyahEntity(
            surah: surahNumber,
            ayah: v,
            text: _verseText(surahNumber, v),
            page: page,
            juz: quran.getJuzNumber(surahNumber, v),
            isSajda: quran.isSajdahVerse(surahNumber, v),
          ),
      ];

      blocks.add(
        SurahBlock(
          surahNumber: surahNumber,
          surahNameAr: surahNameAr(surahNumber),
          revelation: quran.getPlaceOfRevelation(surahNumber),
          totalVerses: quran.getVerseCount(surahNumber),
          isSurahStart: isSurahStart,
          // Al-Fatiha's basmala is ayah 1; At-Tawbah (9) has none.
          showBasmala: isSurahStart && surahNumber != 1 && surahNumber != 9,
          ayat: ayat,
        ),
      );
    }

    final content = PageContent(
      pageNumber: page,
      juz: blocks.isNotEmpty ? blocks.first.ayat.first.juz : 1,
      blocks: blocks,
    );
    _pageCache[page] = content;
    return content;
  }

  /// All 6236 ayat, built once and cached.
  List<AyahEntity> allAyat() {
    final existing = _allAyat;
    if (existing != null) return existing;

    final list = <AyahEntity>[];
    for (int page = 1; page <= kQuranPageCount; page++) {
      for (final block in pageContent(page).blocks) {
        list.addAll(block.ayat);
      }
    }
    _allAyat = list;
    _normalizedAyat = list.map((a) => normalizeArabic(a.text)).toList();
    return list;
  }

  /// Full-text ayah search, harakat/spelling tolerant.
  List<AyahSearchHit> search(String query, {int limit = 60}) {
    final q = normalizeArabic(query);
    if (q.length < 2) return const [];

    final ayat = allAyat();
    final normalized = _normalizedAyat!;
    final hits = <AyahSearchHit>[];

    for (int i = 0; i < ayat.length; i++) {
      if (normalized[i].contains(q)) {
        final a = ayat[i];
        hits.add(
          AyahSearchHit(
            surah: a.surah,
            surahNameAr: surahNameAr(a.surah),
            ayah: a.ayah,
            page: a.page,
            juz: a.juz,
            text: a.text,
          ),
        );
        if (hits.length >= limit) break;
      }
    }
    return hits;
  }
}
