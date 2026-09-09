import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/arabic.dart';
import '../../../core/utils/responsive.dart';

/// A pill showing a value + optional label, sized responsively.
class ReaderStatChip extends StatelessWidget {
  final IconData? icon;
  final String value;
  final String label;

  const ReaderStatChip({
    super.key,
    required this.value,
    this.label = '',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.gap(11),
        vertical: context.gap(5),
      ),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: context.sp(13), color: AppColors.blueGreen),
            SizedBox(width: context.gap(4)),
          ],
          if (label.isNotEmpty) ...[
            Text(
              label,
              style: AppTextStyles.bodyAr(
                fontSize: context.sp(11),
                color: AppColors.blueGreen,
              ),
            ),
            SizedBox(width: context.gap(4)),
          ],
          Text(
            value,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.heading(
              fontSize: context.sp(15),
              color: AppColors.spearmint,
            ),
          ),
        ],
      ),
    );
  }
}

/// AppBar title: surah name + juz, wraps instead of overflowing at large text.
class ReaderHeaderTitle extends StatelessWidget {
  final String surahName;
  final int juz;

  const ReaderHeaderTitle({
    super.key,
    required this.surahName,
    required this.juz,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: context.gap(8),
      runSpacing: context.gap(4),
      children: [
        ReaderStatChip(value: surahName, icon: Icons.menu_book_rounded),
        ReaderStatChip(
            value: toArabicDigits(juz),
            label: 'الجزء',
            icon: Icons.bookmarks_rounded),
      ],
    );
  }
}

/// Bottom bar: page number, and today's khatma range if a khatma is active.
class ReaderFooter extends StatelessWidget {
  final int page;
  final String? wird;

  const ReaderFooter({super.key, required this.page, this.wird});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.forestGreen,
        border: Border(
          top: BorderSide(color: Color(0x33499FA4)),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: context.gap(7)),
      child: SafeArea(
        top: false,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'صفحة ${toArabicDigits(page)}',
                textDirection: TextDirection.rtl,
                style: AppTextStyles.bodyAr(
                  fontSize: context.sp(13),
                  color: Colors.white,
                  weight: FontWeight.w600,
                ),
              ),
              if (wird != null) ...[
                SizedBox(width: context.gap(10)),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.blueGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: context.gap(10)),
                Text(
                  wird!,
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.bodyAr(
                    fontSize: context.sp(12),
                    color: Colors.white70,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
