import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/arabic.dart';
import '../data/quran_repository.dart';
import 'reader_palette.dart';

/// One justified, right-to-left paragraph for a run of ayat from a single surah.
class AyahParagraph extends StatelessWidget {
  final SurahBlock block;
  final ReaderPalette palette;
  final double fontScale;
  final double lineHeight;

  const AyahParagraph({
    super.key,
    required this.block,
    required this.palette,
    required this.fontScale,
    required this.lineHeight,
  });

  @override
  Widget build(BuildContext context) {
    final double base = 22 * fontScale;

    final spans = <InlineSpan>[];
    for (final a in block.ayat) {
      spans.add(TextSpan(text: '${a.text} '));
      spans.add(
        TextSpan(
          // U+06DD (end of ayah) shapes as a rosette enclosing the digits
          // in the Amiri Quran font.
          text: '۝${toArabicDigits(a.ayah)}  ',
          style: TextStyle(
            color: palette.accent,
            fontSize: base * 0.92,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text.rich(
        TextSpan(children: spans),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.justify,
        style: AppTextStyles.quranBody.copyWith(
          fontSize: base,
          height: lineHeight,
          color: palette.ink,
        ),
      ),
    );
  }
}
