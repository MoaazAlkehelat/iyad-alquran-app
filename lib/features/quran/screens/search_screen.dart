import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/quran_constants.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/arabic.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/surah_model.dart';
import '../../../data/services/quran_service.dart';
import '../data/quran_repository.dart';
import 'reader_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _repo = QuranRepository.instance;
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  List<Surah> _allSurahs = [];
  List<Surah> _surahMatches = [];
  List<AyahSearchHit> _ayahMatches = [];
  String _query = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final list = await QuranService.fetchSurahList();
      if (!mounted) return;
      setState(() {
        _allSurahs = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), _runSearch);
  }

  void _runSearch() {
    final raw = _searchCtrl.text.trim();
    final q = normalizeArabic(raw);
    if (q.length < 2) {
      setState(() {
        _query = raw;
        _surahMatches = [];
        _ayahMatches = [];
      });
      return;
    }
    setState(() {
      _query = raw;
      _surahMatches = _allSurahs
          .where((s) => normalizeArabic(s.nameArabic).contains(q))
          .toList();
      _ayahMatches = _repo.search(raw);
    });
  }

  void _openReader(int page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReaderScreen(initialPage: page)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _searchBar(),
            _stats(),
            const SizedBox(height: 10),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.teal))
                  : _error != null
                      ? _errorView()
                      : _results(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.xl, AppSpace.xl, AppSpace.xl, AppSpace.md),
      child: Column(
        children: [
          Text('ابحث في القرآن الكريم',
              textDirection: TextDirection.rtl,
              style: AppTextStyles.heading(
                  fontSize: 24, color: AppColors.spearmint)),
          const SizedBox(height: AppSpace.xs),
          Text('باسم السورة أو بنص الآية',
              textDirection: TextDirection.rtl,
              style: AppTextStyles.caption.copyWith(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.fieldR,
          border: AppSurface.hairlineStrong,
        ),
        child: TextField(
          controller: _searchCtrl,
          textDirection: TextDirection.rtl,
          style: AppTextStyles.bodyAr(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'ابحث عن سورة أو آية...',
            hintTextDirection: TextDirection.rtl,
            hintStyle: AppTextStyles.bodyAr(color: Colors.white54),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.blueGreen),
            suffixIcon: _searchCtrl.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.blueGreen),
                    onPressed: () => _searchCtrl.clear(),
                  ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _stats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.xl, AppSpace.lg, AppSpace.xl, 0),
      child: Row(
        children: [
          _chip(toArabicDigits(kQuranSurahCount), 'سورة'),
          const SizedBox(width: AppSpace.sm),
          _chip(toArabicDigits(kQuranVerseCount), 'آية'),
          const SizedBox(width: AppSpace.sm),
          _chip(toArabicDigits(kQuranJuzCount), 'جزء'),
        ],
      ),
    );
  }

  Widget _chip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: AppTextStyles.numeric(color: AppColors.teal, fontSize: 13)),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _results() {
    final showingSearch = normalizeArabic(_query).length >= 2;
    Widget wrap(Widget child) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: child,
          ),
        );

    if (!showingSearch) {
      return wrap(ListView.separated(
        padding: AppSpace.screen,
        itemCount: _allSurahs.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpace.md),
        itemBuilder: (_, i) => _surahRow(_allSurahs[i]),
      ));
    }

    if (_surahMatches.isEmpty && _ayahMatches.isEmpty) {
      return Center(
        child: Text('لا توجد نتائج',
            style: AppTextStyles.bodyMuted.copyWith(fontSize: 16)),
      );
    }

    return wrap(ListView(
      padding: AppSpace.screen,
      children: [
        if (_surahMatches.isNotEmpty) ...[
          const SectionHeader('السور'),
          for (final s in _surahMatches) ...[
            _surahRow(s),
            const SizedBox(height: AppSpace.md),
          ],
          const SizedBox(height: AppSpace.sm),
        ],
        if (_ayahMatches.isNotEmpty) ...[
          SectionHeader('الآيات (${toArabicDigits(_ayahMatches.length)})'),
          for (final h in _ayahMatches) ...[
            _ayahRow(h),
            const SizedBox(height: AppSpace.md),
          ],
        ],
      ],
    ));
  }

  Widget _surahRow(Surah surah) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.lg, vertical: AppSpace.md),
      onTap: () => _openReader(_repo.pageForSurah(surah.id)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.field),
            ),
            child: Center(
              child: Text(toArabicDigits(surah.id),
                  style: AppTextStyles.numeric(
                      color: AppColors.teal, fontSize: 15)),
            ),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(surah.nameArabic,
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.surahTitle(
                        color: AppColors.spearmint, fontSize: 20)),
                const SizedBox(height: 2),
                Text('${toArabicDigits(surah.totalVerses)} آية',
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.caption.copyWith(fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_left_rounded,
              color: AppColors.teal, size: 22),
        ],
      ),
    );
  }

  Widget _ayahRow(AyahSearchHit hit) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpace.lg),
      onTap: () => _openReader(hit.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            hit.text,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.quranBody
                .copyWith(color: Colors.white, fontSize: 18, height: 1.95),
          ),
          const SizedBox(height: AppSpace.sm),
          Row(
            children: [
              Text('سورة ${hit.surahNameAr}',
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.caption.copyWith(fontSize: 12)),
              const SizedBox(width: 6),
              Text('• آية ${toArabicDigits(hit.ayah)} • صفحة ${toArabicDigits(hit.page)}',
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.caption
                      .copyWith(fontSize: 12, color: Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.teal, size: 56),
            const SizedBox(height: 14),
            Text('حدث خطأ أثناء تحميل السور',
                textDirection: TextDirection.rtl,
                style: AppTextStyles.heading(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: AppColors.forestGreen),
              onPressed: _load,
              child: Text('إعادة المحاولة',
                  style: AppTextStyles.bodyAr(weight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
