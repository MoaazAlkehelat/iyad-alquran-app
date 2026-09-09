import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/arabic.dart';
import '../data/quran_repository.dart';
import 'reader_palette.dart';

/// One justified, right-to-left paragraph for a run of ayat from a single surah.
class AyahParagraph extends StatelessWidget {
  final List<AyahEntity> ayat;
  final ReaderPalette palette;
  final double fontScale;
  final double lineHeight;

  /// When set, that ayah's text gets a faint highlight (used on arrival from
  /// search so the searched ayah stands out).
  final int? highlightAyah;

  const AyahParagraph({
    super.key,
    required this.ayat,
    required this.palette,
    required this.fontScale,
    required this.lineHeight,
    this.highlightAyah,
  });

  @override
  Widget build(BuildContext context) {
    final double base = 22 * fontScale;

    final spans = <InlineSpan>[];
    for (final a in ayat) {
      spans.add(TextSpan(
        text: '${a.text} ',
        style: a.ayah == highlightAyah
            ? TextStyle(
                backgroundColor: palette.accent.withValues(alpha: 0.16),
              )
            : null,
      ));
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
