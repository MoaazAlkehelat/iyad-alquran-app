import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../data/quran_repository.dart';
import 'reader_palette.dart';

class Basmala extends StatelessWidget {
  final ReaderPalette palette;
  final double fontScale;

  const Basmala({super.key, required this.palette, this.fontScale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.gap(6), bottom: context.gap(10)),
      child: Text(
        QuranRepository.basmala,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        style: AppTextStyles.basmala.copyWith(
          fontSize: context.sp(20) * fontScale,
          height: 1.9,
          color: palette.ink,
        ),
      ),
    );
  }
}
