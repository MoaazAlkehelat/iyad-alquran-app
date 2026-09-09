import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/state/app_settings.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/arabic.dart';

/// Everything the reader's app bar used to spread across three icons —
/// font size, reading layout, dark mode — folded into one bottom sheet.
///
/// Opened with:
/// ```dart
/// showModalBottomSheet<void>(
///   context: context,
///   backgroundColor: AppColors.forestGreen,
///   shape: const RoundedRectangleBorder(
///     borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
///   ),
///   builder: (_) => const ReaderOptionsSheet(),
/// );
/// ```
class ReaderOptionsSheet extends StatelessWidget {
  const ReaderOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpace.lg, AppSpace.md, AppSpace.lg, AppSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpace.lg),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text('إعدادات القراءة',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: AppTextStyles.heading(color: Colors.white, fontSize: 17)),
            const SizedBox(height: AppSpace.lg),
            _fontSizeRow(settings),
            const SizedBox(height: AppSpace.lg),
            _layoutRow(settings),
            const SizedBox(height: AppSpace.lg),
            _darkModeRow(settings),
          ],
        ),
      ),
    );
  }

  Widget _rowLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.teal, size: 20),
        const SizedBox(width: AppSpace.sm),
        Text(text,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.bodyAr(color: Colors.white, fontSize: 15)),
      ],
    );
  }

  Widget _fontSizeRow(AppSettings settings) {
    return Row(
      children: [
        Expanded(child: _rowLabel('حجم الخط', Icons.format_size_rounded)),
        IconButton(
          onPressed: () => settings.bumpFontScale(-0.1),
          icon: const Icon(Icons.text_decrease_rounded, color: Colors.white),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '٪${toArabicDigits((settings.readingFontScale * 100).round())}',
            textAlign: TextAlign.center,
            style: AppTextStyles.numeric(color: AppColors.blueGreen, fontSize: 13),
          ),
        ),
        IconButton(
          onPressed: () => settings.bumpFontScale(0.1),
          icon: const Icon(Icons.text_increase_rounded, color: Colors.white),
        ),
      ],
    );
  }

  Widget _layoutRow(AppSettings settings) {
    return Row(
      children: [
        Expanded(child: _rowLabel('اتجاه القراءة', Icons.swap_vert_rounded)),
        SegmentedButton<ReaderLayout>(
          segments: const [
            ButtonSegment(
              value: ReaderLayout.vertical,
              icon: Icon(Icons.swap_vert_rounded, size: 18),
              label: Text('عمودي'),
            ),
            ButtonSegment(
              value: ReaderLayout.horizontal,
              icon: Icon(Icons.swap_horiz_rounded, size: 18),
              label: Text('أفقي'),
            ),
          ],
          selected: {settings.readerLayout},
          showSelectedIcon: false,
          onSelectionChanged: (s) => settings.setReaderLayout(s.first),
          style: SegmentedButton.styleFrom(
            backgroundColor: AppColors.background,
            foregroundColor: Colors.white70,
            selectedBackgroundColor: AppColors.teal,
            selectedForegroundColor: Colors.black,
            textStyle: AppTextStyles.bodyAr(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _darkModeRow(AppSettings settings) {
    return Row(
      children: [
        Expanded(
          child: _rowLabel(
            settings.isDarkMode ? 'الوضع الليلي' : 'الوضع النهاري',
            settings.isDarkMode
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
          ),
        ),
        Switch(
          value: settings.isDarkMode,
          activeThumbColor: AppColors.teal,
          onChanged: settings.setDarkMode,
        ),
      ],
    );
  }
}
