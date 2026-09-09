import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/arabic.dart';
import '../../../core/utils/responsive.dart';
import 'reader_palette.dart';

/// Thin separator shown between pages in the continuous scroll:
/// a hairline with a small centred "٤٣ · جـ ٣" marker.
class PageDivider extends StatelessWidget {
  final int page;
  final int juz;
  final ReaderPalette palette;

  const PageDivider({
    super.key,
    required this.page,
    required this.juz,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final line = palette.faintLine;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.gap(18)),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: line)),
          Container(
            margin: EdgeInsets.symmetric(horizontal: context.gap(12)),
            padding: EdgeInsets.symmetric(
              horizontal: context.gap(10),
              vertical: context.gap(3),
            ),
            decoration: BoxDecoration(
              border: Border.all(color: line),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${toArabicDigits(page)} · جـ ${toArabicDigits(juz)}',
              textDirection: TextDirection.rtl,
              style: AppTextStyles.bodyAr(
                fontSize: context.sp(11),
                color: palette.subtitle,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: line)),
        ],
      ),
    );
  }
}
