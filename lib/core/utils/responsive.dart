import 'package:flutter/widgets.dart';

/// Lightweight responsive sizing. Scales a base pixel value by the device's
/// shortest side relative to a 390px baseline, clamped so phones and tablets
/// both stay sensible. Use for header/footer chrome, the Khatma card and the
/// surah header — not for the reflowing ayah text, which is driven by
/// [AppSettings.readingFontScale] + the app-level textScaler instead.
extension Responsive on BuildContext {
  double get responsiveScale {
    final shortest = MediaQuery.sizeOf(this).shortestSide;
    return (shortest / 390.0).clamp(0.85, 1.35);
  }

  /// Scaled font size.
  double sp(double base) => base * responsiveScale;

  /// Scaled spacing / dimension.
  double gap(double base) => base * responsiveScale;
}
