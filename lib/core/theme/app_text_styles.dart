import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Central typography. All families are bundled in assets/fonts (no runtime
/// download): [AmiriQuran] for Quranic text, [Amiri] for display/headings,
/// [Cairo] for UI/body text.
class AppFont {
  static const quran = 'AmiriQuran';
  static const heading = 'Amiri';
  static const body = 'Cairo';
}

class AppTextStyles {
  AppTextStyles._();

  // ---- Fixed UI scale (use these first; fall back to the builders below) ----

  /// Big screen title / user name.
  static const TextStyle display = TextStyle(
    fontFamily: AppFont.heading,
    fontWeight: FontWeight.bold,
    fontSize: 30,
    height: 1.15,
    color: Colors.white,
  );

  /// Card / screen headline.
  static const TextStyle title = TextStyle(
    fontFamily: AppFont.heading,
    fontWeight: FontWeight.bold,
    fontSize: 20,
    height: 1.2,
    color: Colors.white,
  );

  /// Small caps-feel label above a group of content.
  static const TextStyle sectionLabel = TextStyle(
    fontFamily: AppFont.body,
    fontWeight: FontWeight.w700,
    fontSize: 12,
    height: 1.2,
    letterSpacing: 0.6,
    color: AppColors.blueGreen,
  );

  static const TextStyle body = TextStyle(
    fontFamily: AppFont.body,
    fontSize: 14,
    height: 1.5,
    color: Colors.white,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: AppFont.body,
    fontSize: 14,
    height: 1.5,
    color: Colors.white70,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: AppFont.body,
    fontSize: 12,
    height: 1.4,
    color: AppColors.blueGreen,
  );

  // ---- Quranic ----

  /// The reflowing mushaf text. Size/height come from AppSettings.
  static const TextStyle quranBody = TextStyle(
    fontFamily: AppFont.quran,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle basmala = TextStyle(
    fontFamily: AppFont.quran,
    fontWeight: FontWeight.w400,
  );

  // ---- Builders (kept for call sites that need a one-off size/colour) ----

  static TextStyle surahTitle({double? fontSize, Color? color}) => TextStyle(
        fontFamily: AppFont.heading,
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
        color: color,
      );

  static TextStyle heading({double? fontSize, Color? color, FontWeight? weight}) =>
      TextStyle(
        fontFamily: AppFont.heading,
        fontWeight: weight ?? FontWeight.bold,
        fontSize: fontSize,
        color: color,
      );

  static TextStyle bodyAr({double? fontSize, Color? color, FontWeight? weight}) =>
      TextStyle(
        fontFamily: AppFont.body,
        fontWeight: weight,
        fontSize: fontSize,
        height: 1.5,
        color: color,
      );

  static TextStyle numeric({double? fontSize, Color? color, FontWeight? weight}) =>
      TextStyle(
        fontFamily: AppFont.body,
        fontFeatures: const [FontFeature.tabularFigures()],
        fontWeight: weight ?? FontWeight.w700,
        fontSize: fontSize,
        color: color,
      );
}
