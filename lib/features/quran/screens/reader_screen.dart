import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/quran_constants.dart';
import '../../../core/state/app_settings.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/arabic.dart';
import '../../../data/models/bookmark_model.dart';
import '../../../data/models/khatma_model.dart';
import '../../../data/services/app_state_service.dart';
import '../../../data/services/khatma_service.dart';
import '../../../data/services/preferences_service.dart';
import '../data/quran_repository.dart';
import '../widgets/ayah_paragraph.dart';
import '../widgets/basmala.dart';
import '../widgets/page_divider.dart';
import '../widgets/reader_chrome.dart';
import '../widgets/reader_palette.dart';
import '../widgets/surah_header.dart';

class ReaderScreen extends StatefulWidget {
  final String surahName;
  final int initialPage;

  const ReaderScreen({
    super.key,
    this.surahName = '',
    required this.initialPage,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final _repo = QuranRepository.instance;
  final _itemScrollController = ItemScrollController();
  final _positionsListener = ItemPositionsListener.create();

  late int _currentPage;
  KhatmaModel? _khatma;
  Timer? _saveDebounce;

  int get _initialIndex =>
      (widget.initialPage.clamp(1, kQuranPageCount)) - 1;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.clamp(1, kQuranPageCount);
    _positionsListener.itemPositions.addListener(_onScroll);
    _loadKhatma();
  }

  @override
  void dispose() {
    _positionsListener.itemPositions.removeListener(_onScroll);
    _saveDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadKhatma() async {
    final k = await KhatmaService.getKhatma();
    if (mounted) setState(() => _khatma = k);
  }

  void _onScroll() {
    final positions = _positionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final visible = positions
        .where((p) => p.itemTrailingEdge > 0 && p.itemLeadingEdge < 1)
        .toList()
      ..sort((a, b) => a.itemLeadingEdge.compareTo(b.itemLeadingEdge));
    if (visible.isEmpty) return;

    final page = visible.first.index + 1;
    if (page != _currentPage) {
      setState(() => _currentPage = page);
      _schedulePersist(page);
    }
  }

  void _schedulePersist(int page) {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 450), () async {
      await AppStateService.saveLastPage(page);

      final k = _khatma;
      if (k != null && page > k.currentPage) {
        final updated = k.copyWith(
          currentPage: page,
          completed: page >= kQuranPageCount,
          lastReadDate: DateTime.now(),
        );
        await KhatmaService.saveKhatma(updated);
        if (mounted) _khatma = updated;
      }
    });
  }

  Future<void> _addBookmark() async {
    final controller = TextEditingController(
      text: '${_repo.surahNameAr(_repo.pageContent(_currentPage).blocks.first.surahNumber)}'
          ' - صفحة ${toArabicDigits(_currentPage)}',
    );
    final name = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.forestGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('اسم العلامة',
            textDirection: TextDirection.rtl,
            style: AppTextStyles.heading(color: Colors.white, fontSize: 18)),
        content: TextField(
          controller: controller,
          textDirection: TextDirection.rtl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'اكتب اسم العلامة',
            hintTextDirection: TextDirection.rtl,
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: AppColors.background,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.teal),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.blueGreen, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('إلغاء', style: AppTextStyles.bodyAr(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(dialogCtx, controller.text.trim()),
            child: Text('حفظ', style: AppTextStyles.bodyAr(weight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return;
    await PreferencesService.saveBookmark(
      BookmarkModel(name: name, page: _currentPage),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.forestGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: const Text('تم حفظ العلامة بنجاح',
            textDirection: TextDirection.rtl,
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final palette = ReaderPalette(settings.isDarkMode);
    final pageData = _repo.pageContent(_currentPage);
    final surahName = _repo.surahNameAr(pageData.blocks.first.surahNumber);

    String? wird;
    final k = _khatma;
    if (k != null) {
      final s = KhatmaService.getTodayStartPage(k);
      final e = KhatmaService.getTodayEndPage(k);
      wird = 'ورد اليوم: ${toArabicDigits(s)} - ${toArabicDigits(e)}';
    }

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        titleSpacing: 8,
        scrolledUnderElevation: 0,
        title: ReaderHeaderTitle(surahName: surahName, juz: pageData.juz),
        actions: [
          _FontSizeButton(settings: settings),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'علامة مرجعية',
            onPressed: _addBookmark,
            icon: const Icon(Icons.bookmark_add_outlined),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: settings.isDarkMode ? 'الوضع النهاري' : 'الوضع الليلي',
            onPressed: settings.toggleDarkMode,
            icon: Icon(settings.isDarkMode
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ScrollablePositionedList.builder(
        itemScrollController: _itemScrollController,
        itemPositionsListener: _positionsListener,
        initialScrollIndex: _initialIndex,
        itemCount: kQuranPageCount,
        itemBuilder: (context, index) => _PageView(
          content: _repo.pageContent(index + 1),
          palette: palette,
          fontScale: settings.readingFontScale,
          lineHeight: settings.lineHeight,
        ),
      ),
      bottomNavigationBar: ReaderFooter(page: _currentPage, wird: wird),
    );
  }
}

class _PageView extends StatelessWidget {
  final PageContent content;
  final ReaderPalette palette;
  final double fontScale;
  final double lineHeight;

  const _PageView({
    required this.content,
    required this.palette,
    required this.fontScale,
    required this.lineHeight,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final block in content.blocks) {
      if (block.isSurahStart) {
        children.add(SurahHeader(block: block, palette: palette));
      }
      if (block.showBasmala) {
        children.add(Basmala(palette: palette, fontScale: fontScale));
      }
      children.add(AyahParagraph(
        block: block,
        palette: palette,
        fontScale: fontScale,
        lineHeight: lineHeight,
      ));
    }
    children.add(PageDivider(
      page: content.pageNumber,
      juz: content.juz,
      palette: palette,
    ));

    return RepaintBoundary(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

/// AppBar control that folds A- / % / A+ into one slot.
class _FontSizeButton extends StatelessWidget {
  final AppSettings settings;
  const _FontSizeButton({required this.settings});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      tooltip: 'حجم الخط',
      icon: const Icon(Icons.format_size_rounded),
      color: AppColors.forestGreen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (_) => [
        PopupMenuItem<void>(
          enabled: false,
          child: StatefulBuilder(
            builder: (context, setInner) {
              void bump(double d) {
                settings.bumpFontScale(d);
                setInner(() {});
              }

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => bump(-0.1),
                    icon: const Icon(Icons.text_decrease_rounded,
                        color: Colors.white),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '٪${toArabicDigits((settings.readingFontScale * 100).round())}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.numeric(
                          color: AppColors.blueGreen, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    onPressed: () => bump(0.1),
                    icon: const Icon(Icons.text_increase_rounded,
                        color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
