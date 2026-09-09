import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Colours for the reading surface, derived from the dark-mode flag.
class ReaderPalette {
  final bool isDark;
  const ReaderPalette(this.isDark);

  Color get background => isDark ? AppColors.background : AppColors.parchment;
  Color get ink => isDark ? AppColors.inkOnDark : AppColors.inkOnParchment;
  Color get accent => isDark ? AppColors.blueGreen : AppColors.teal;
  Color get frame => AppColors.teal;
  Color get frameFill =>
      isDark ? AppColors.surface.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.6);
  Color get faintLine => AppColors.teal.withValues(alpha: isDark ? 0.35 : 0.28);
  Color get subtitle =>
      (isDark ? AppColors.blueGreen : AppColors.teal).withValues(alpha: 0.9);
}
