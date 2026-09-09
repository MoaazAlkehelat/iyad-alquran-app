import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/quran_constants.dart';
import '../../../core/state/app_settings.dart';
import '../../../core/theme/app_dimens.dart';
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
import '../widgets/pinch_to_scale.dart';
import '../widgets/reader_chrome.dart';
import '../widgets/reader_options_sheet.dart';
import '../widgets/reader_palette.dart';
import '../widgets/surah_header.dart';

class ReaderScreen extends StatefulWidget {
  final String surahName;
  final int initialPage;

  /// When set, after the page loads the reader scrolls so this surah's block
  /// (on [initialPage]) sits at the top — used by search so tapping "الناس"
  /// lands on An-Nas, not the top of page 604.
  final int? initialSurah;
  final int? initialAyah;

  const ReaderScreen({
    super.key,
    this.surahName = '',
    required this.initialPage,
    this.initialSurah,
    this.initialAyah,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final _repo = QuranRepository.instance;
  final _itemScrollController = ItemScrollController();
  final _offsetController = ScrollOffsetController();
  final _positionsListener = ItemPositionsListener.create();

  late int _currentPage;
  late String _topSurahName;
  late int _topJuz;
  KhatmaModel? _khatma;
  Timer? _saveDebounce;

  bool _autoScroll = false;
  double _autoSpeed = 1.5; // multiplier, 0.5 – 4.0
  bool _speedVisible = false;
  Timer? _speedHideTimer;

  final _targetKey = GlobalKey();
  int? _highlightAyah;
  Timer? _highlightTimer;

  /// Live pinch target (absolute font scale) while a two-finger gesture is in
  /// flight, else null. Drives a compositor-only [Transform.scale] so the pinch
  /// stays at 60fps; the real font scale (which reflows every page) is only
  /// applied once, on gesture end.
  final ValueNotifier<double?> _pinchTargetScale = ValueNotifier(null);

  /// Only used in horizontal (page-flip) mode; created lazily so it can be
  /// seeded with whatever page is currently being read (see [_syncPageController]).
  PageController? _pageController;
  ReaderLayout? _lastLayout;

  int get _initialIndex =>
      (widget.initialPage.clamp(1, kQuranPageCount)) - 1;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.clamp(1, kQuranPageCount);
    _highlightAyah = widget.initialAyah;
    final first = _repo.pageContent(_currentPage).blocks.first;
    _topSurahName = first.surahNameAr;
    _topJuz = first.ayat.first.juz;
    _positionsListener.itemPositions.addListener(_onScroll);
    _loadKhatma();
    if (widget.initialSurah != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTarget(0));
    }
  }

  void _scrollToTarget(int attempt) {
    if (!mounted || attempt > 8) return;
    final ctx = _targetKey.currentContext;
    if (ctx == null) {
      Future.delayed(
          const Duration(milliseconds: 200), () => _scrollToTarget(attempt + 1));
      return;
    }
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.02,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    // Clear the arrival highlight after a few seconds.
    if (_highlightAyah != null) {
      _highlightTimer?.cancel();
      _highlightTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _highlightAyah = null);
      });
    }
  }

  @override
  void dispose() {
    _autoScroll = false;
    _speedHideTimer?.cancel();
    _highlightTimer?.cancel();
    _positionsListener.itemPositions.removeListener(_onScroll);
    _saveDebounce?.cancel();
    _pinchTargetScale.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  void _toggleAutoScroll() {
    setState(() => _autoScroll = !_autoScroll);
    if (_autoScroll) {
      _revealSpeed();
      _autoScrollLoop();
    } else {
      _speedHideTimer?.cancel();
      setState(() => _speedVisible = false);
    }
  }

  void _revealSpeed() {
    setState(() => _speedVisible = true);
    _speedHideTimer?.cancel();
    _speedHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _speedVisible = false);
    });
  }

  void _stopAutoScroll() {
    if (_autoScroll) {
      _speedHideTimer?.cancel();
      setState(() {
        _autoScroll = false;
        _speedVisible = false;
      });
    }
  }

  Future<void> _autoScrollLoop() async {
    while (_autoScroll && mounted) {
      if (_currentPage >= kQuranPageCount) {
        _stopAutoScroll();
        break;
      }
      try {
        await _offsetController.animateScroll(
          offset: _autoSpeed * 12,
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
        );
      } catch (_) {
        break;
      }
    }
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

    final top = visible.first;
    final page = top.index + 1;
    _updateTopSurah(top);

    if (page != _currentPage) {
      setState(() => _currentPage = page);
      _schedulePersist(page);
    }
  }

  /// The surah/juz shown in the header should reflect what's at the *top* of the
  /// viewport, not just the page's first surah. Pages with several short surahs
  /// (e.g. 604) are split by weighting each block by its ayah count.
  void _updateTopSurah(ItemPosition top) {
    final blocks = _repo.pageContent(top.index + 1).blocks;
    late String name;
    late int juz;

    if (blocks.length == 1) {
      name = blocks.first.surahNameAr;
      juz = blocks.first.ayat.first.juz;
    } else {
      final span = top.itemTrailingEdge - top.itemLeadingEdge;
      final scrolled =
          span <= 0 ? 0.0 : (-top.itemLeadingEdge / span).clamp(0.0, 1.0);
      final weights = blocks
          .map((b) =>
              b.ayat.length + (b.isSurahStart ? 3 : 0) + (b.showBasmala ? 1 : 0))
          .toList();
      final total = weights.fold<int>(0, (a, b) => a + b);
      var acc = 0.0;
      var current = blocks.first;
      for (var i = 0; i < blocks.length; i++) {
        acc += weights[i] / total;
        current = blocks[i];
        if (scrolled < acc) break;
      }
      name = current.surahNameAr;
      juz = current.ayat.first.juz;
    }

    if (name != _topSurahName || juz != _topJuz) {
      setState(() {
        _topSurahName = name;
        _topJuz = juz;
      });
    }
  }

  /// Called from [build] whenever the reading layout changes. When switching
  /// into horizontal (page-flip) mode, (re)creates the [PageController] so it
  /// opens on whatever page is currently being read — not wherever a stale
  /// controller was last left. The previous controller (if any) is disposed a
  /// frame later, once the [PageView] that held it has already been torn
  /// down; disposing it synchronously here would race that teardown.
  void _syncPageController(ReaderLayout layout) {
    if (layout == _lastLayout) return;
    if (layout == ReaderLayout.horizontal) {
      final old = _pageController;
      _pageController = PageController(initialPage: _currentPage - 1);
      if (old != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      }
    }
    _lastLayout = layout;
  }

  /// Page-flip equivalent of [_onScroll]: a full page is always either fully
  /// on screen or not, so there's no partial-scroll weighting to do — just
  /// take the new page's first block.
  void _onPageChanged(int index) {
    final page = index + 1;
    final first = _repo.pageContent(page).blocks.first;
    setState(() {
      _currentPage = page;
      _topSurahName = first.surahNameAr;
      _topJuz = first.ayat.first.juz;
    });
    _schedulePersist(page);
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

  void _openReaderOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.forestGreen,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => const ReaderOptionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final palette = ReaderPalette(settings.isDarkMode);
    _syncPageController(settings.readerLayout);

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
        title: ReaderHeaderTitle(surahName: _topSurahName, juz: _topJuz),
        actions: [
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'علامة مرجعية',
            onPressed: _addBookmark,
            icon: const Icon(Icons.bookmark_add_outlined),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'إعدادات القراءة',
            onPressed: _openReaderOptions,
            icon: const Icon(Icons.tune_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: settings.readerLayout == ReaderLayout.vertical
          ? _AutoScrollControl(
              active: _autoScroll,
              speed: _autoSpeed,
              speedVisible: _speedVisible,
              onToggle: _toggleAutoScroll,
              onRevealSpeed: _revealSpeed,
              onSpeed: (v) {
                setState(() => _autoSpeed = v);
                _revealSpeed();
              },
            )
          : null,
      body: Listener(
        // A finger on the page stops the auto-scroller.
        onPointerDown: (_) => _stopAutoScroll(),
        child: PinchToScale(
          scale: settings.readingFontScale,
          min: AppSettings.minFontScale,
          max: AppSettings.maxFontScale,
          onScalePreview: (v) => _pinchTargetScale.value = v,
          onScaleCommit: (v) {
            settings.setReadingFontScale(v);
            _pinchTargetScale.value = null;
          },
          child: ClipRect(
            child: ValueListenableBuilder<double?>(
              valueListenable: _pinchTargetScale,
              builder: (context, target, child) {
                final base = settings.readingFontScale;
                final factor = (target == null || base == 0) ? 1.0 : target / base;
                return Transform.scale(
                  scale: factor,
                  alignment: Alignment.topCenter,
                  filterQuality: FilterQuality.medium,
                  child: child,
                );
              },
              child: settings.readerLayout == ReaderLayout.horizontal
                  ? _buildHorizontalPager(palette, settings)
                  : _buildVerticalList(palette, settings),
            ),
          ),
        ),
      ),
      bottomNavigationBar: ReaderFooter(page: _currentPage, wird: wird),
    );
  }

  Widget _buildVerticalList(ReaderPalette palette, AppSettings settings) {
    return ScrollablePositionedList.builder(
      itemScrollController: _itemScrollController,
      scrollOffsetController: _offsetController,
      itemPositionsListener: _positionsListener,
      initialScrollIndex: _initialIndex,
      itemCount: kQuranPageCount,
      itemBuilder: (context, index) => _pageItem(index, palette, settings),
    );
  }

  /// One full mushaf page per swipe. Each page is wrapped in its own
  /// [SingleChildScrollView] because [PageView] gives every page tight,
  /// viewport-sized constraints — a page whose content is taller than the
  /// screen (e.g. at a larger font scale) needs to scroll internally. That
  /// inner scroll is a different axis than the pager's own drag, so there's
  /// no gesture-arena conflict (same reasoning as [PinchToScale]).
  Widget _buildHorizontalPager(ReaderPalette palette, AppSettings settings) {
    return PageView.builder(
      controller: _pageController,
      itemCount: kQuranPageCount,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) => SingleChildScrollView(
        child: _pageItem(index, palette, settings),
      ),
    );
  }

  Widget _pageItem(int index, ReaderPalette palette, AppSettings settings) {
    return _PageView(
      content: _repo.pageContent(index + 1),
      palette: palette,
      fontScale: settings.readingFontScale,
      lineHeight: settings.lineHeight,
      targetSurah:
          (index + 1 == widget.initialPage) ? widget.initialSurah : null,
      targetAyah:
          (index + 1 == widget.initialPage) ? widget.initialAyah : null,
      highlightAyah:
          (index + 1 == widget.initialPage) ? _highlightAyah : null,
      targetKey: _targetKey,
    );
  }
}

/// Play/pause the smooth auto-scroller. While running, a speed slider shows for
/// ~3s after each interaction, then collapses to a small speed button.
class _AutoScrollControl extends StatelessWidget {
  final bool active;
  final double speed;
  final bool speedVisible;
  final VoidCallback onToggle;
  final VoidCallback onRevealSpeed;
  final ValueChanged<double> onSpeed;

  const _AutoScrollControl({
    required this.active,
    required this.speed,
    required this.speedVisible,
    required this.onToggle,
    required this.onRevealSpeed,
    required this.onSpeed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (active)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: speedVisible
                ? Container(
                    key: const ValueKey('slider'),
                    width: 210,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: AppColors.teal.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.slow_motion_video_rounded,
                            size: 16, color: AppColors.blueGreen),
                        Expanded(
                          child: Slider(
                            value: speed,
                            min: 0.5,
                            max: 4.0,
                            divisions: 7,
                            activeColor: AppColors.teal,
                            onChanged: onSpeed,
                          ),
                        ),
                        const Icon(Icons.fast_forward_rounded,
                            size: 16, color: AppColors.blueGreen),
                      ],
                    ),
                  )
                : Padding(
                    key: const ValueKey('chip'),
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FloatingActionButton.small(
                      heroTag: 'autoscroll-speed',
                      backgroundColor: AppColors.forestGreen,
                      foregroundColor: AppColors.blueGreen,
                      elevation: 0,
                      onPressed: onRevealSpeed,
                      child: const Icon(Icons.speed_rounded, size: 20),
                    ),
                  ),
          ),
        FloatingActionButton.small(
          heroTag: 'autoscroll',
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.black,
          onPressed: onToggle,
          child: Icon(active ? Icons.pause_rounded : Icons.play_arrow_rounded),
        ),
      ],
    );
  }
}

class _PageView extends StatelessWidget {
  final PageContent content;
  final ReaderPalette palette;
  final double fontScale;
  final double lineHeight;

  /// If this page contains this surah, anchor [targetKey] so the reader can
  /// scroll it to the top. When [targetAyah] is also set, the anchor is placed
  /// at that exact ayah instead of the surah's first ayah.
  final int? targetSurah;
  final int? targetAyah;

  /// Ayah to tint on arrival — cleared by the reader after a few seconds, so it
  /// is kept separate from [targetAyah] (which controls the paragraph split).
  final int? highlightAyah;
  final GlobalKey? targetKey;

  const _PageView({
    required this.content,
    required this.palette,
    required this.fontScale,
    required this.lineHeight,
    this.targetSurah,
    this.targetAyah,
    this.highlightAyah,
    this.targetKey,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final block in content.blocks) {
      final isTargetSurah =
          targetSurah != null && block.surahNumber == targetSurah;
      final ayahInBlock = isTargetSurah &&
          targetAyah != null &&
          targetAyah! >= block.ayat.first.ayah &&
          targetAyah! <= block.ayat.last.ayah;

      final blockChildren = <Widget>[
        if (block.isSurahStart) SurahHeader(block: block, palette: palette),
        if (block.showBasmala) Basmala(palette: palette, fontScale: fontScale),
      ];

      if (ayahInBlock && targetAyah != block.ayat.first.ayah) {
        // Split so the searched ayah starts its own paragraph, and anchor there.
        final before =
            block.ayat.where((a) => a.ayah < targetAyah!).toList();
        final rest = block.ayat.where((a) => a.ayah >= targetAyah!).toList();
        if (before.isNotEmpty) {
          blockChildren.add(AyahParagraph(
            ayat: before,
            palette: palette,
            fontScale: fontScale,
            lineHeight: lineHeight,
          ));
        }
        blockChildren.add(Column(
          key: targetKey,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AyahParagraph(
              ayat: rest,
              palette: palette,
              fontScale: fontScale,
              lineHeight: lineHeight,
              highlightAyah: highlightAyah,
            ),
          ],
        ));
        children.add(Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: blockChildren,
        ));
        continue;
      }

      blockChildren.add(AyahParagraph(
        ayat: block.ayat,
        palette: palette,
        fontScale: fontScale,
        lineHeight: lineHeight,
        highlightAyah: highlightAyah,
      ));
      children.add(Column(
        key: isTargetSurah ? targetKey : null,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: blockChildren,
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
