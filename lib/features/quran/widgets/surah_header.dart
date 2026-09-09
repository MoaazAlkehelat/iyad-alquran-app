import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/arabic.dart';
import '../../../core/utils/responsive.dart';
import '../data/quran_repository.dart';
import 'reader_palette.dart';

/// The decorative frame drawn at the start of every surah — the "border" that
/// used to live baked into the page images. Pure Flutter (CustomPaint), so it
/// themes for light/dark and scales with the device.
class SurahHeader extends StatelessWidget {
  final SurahBlock block;
  final ReaderPalette palette;

  const SurahHeader({super.key, required this.block, required this.palette});

  @override
  Widget build(BuildContext context) {
    final isMakkah = block.revelation.toLowerCase().startsWith('makk');
    final subtitle =
        '${isMakkah ? 'مكية' : 'مدنية'} • ${toArabicDigits(block.totalVerses)} آيات';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.gap(14)),
      child: CustomPaint(
        painter: _FramePainter(
          border: palette.frame,
          fill: palette.frameFill,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.gap(26),
            vertical: context.gap(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'سُورَةُ ${block.surahNameAr}',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: AppTextStyles.surahTitle(
                  fontSize: context.sp(24),
                  color: palette.ink,
                ),
              ),
              SizedBox(height: context.gap(8)),
              _OrnamentRule(color: palette.accent.withValues(alpha: 0.6)),
              SizedBox(height: context.gap(8)),
              Text(
                subtitle,
                textDirection: TextDirection.rtl,
                style: AppTextStyles.bodyAr(
                  fontSize: context.sp(12),
                  color: palette.subtitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrnamentRule extends StatelessWidget {
  final Color color;
  const _OrnamentRule({required this.color});

  @override
  Widget build(BuildContext context) {
    Widget line() => Expanded(
          child: Container(height: 1, color: color.withValues(alpha: 0.5)),
        );
    Widget diamond() => Transform.rotate(
          angle: 0.785398,
          child: Container(width: 5, height: 5, color: color),
        );
    return SizedBox(
      width: 120,
      child: Row(
        children: [line(), const SizedBox(width: 6), diamond(), const SizedBox(width: 6), line()],
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  final Color border;
  final Color fill;

  _FramePainter({required this.border, required this.fill});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final outer = RRect.fromRectAndRadius(
      rect.deflate(1.0),
      const Radius.circular(16),
    );
    final inner = RRect.fromRectAndRadius(
      rect.deflate(5.5),
      const Radius.circular(12),
    );

    canvas.drawRRect(outer, Paint()..color = fill);

    final strokeOuter = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = border.withValues(alpha: 0.9);
    final strokeInner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = border.withValues(alpha: 0.4);

    canvas.drawRRect(outer, strokeOuter);
    canvas.drawRRect(inner, strokeInner);

    // Small corner diamonds sitting on the outer stroke.
    final dot = Paint()..color = border.withValues(alpha: 0.9);
    const inset = 10.0;
    for (final c in [
      Offset(inset, inset),
      Offset(size.width - inset, inset),
      Offset(inset, size.height - inset),
      Offset(size.width - inset, size.height - inset),
    ]) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(0.785398);
      canvas.drawRect(const Rect.fromLTWH(-2.5, -2.5, 5, 5), dot);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_FramePainter old) =>
      old.border != border || old.fill != fill;
}
