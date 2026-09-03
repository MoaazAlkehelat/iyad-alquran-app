import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// One spacing scale so screens stop inventing their own paddings.
class AppSpace {
  AppSpace._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Standard screen edge padding.
  static const EdgeInsets screen = EdgeInsets.fromLTRB(20, 24, 20, 24);
}

/// One radius scale.
class AppRadius {
  AppRadius._();
  static const double chip = 12;
  static const double field = 14;
  static const double card = 20;
  static const double sheet = 24;
  static const double pill = 999;

  static const BorderRadius cardR = BorderRadius.all(Radius.circular(card));
  static const BorderRadius fieldR = BorderRadius.all(Radius.circular(field));
  static const BorderRadius pillR = BorderRadius.all(Radius.circular(pill));
}

/// Shared surface treatments so every card matches.
class AppSurface {
  AppSurface._();

  static Border get hairline =>
      Border.all(color: AppColors.teal.withValues(alpha: 0.16));

  static Border get hairlineStrong =>
      Border.all(color: AppColors.teal.withValues(alpha: 0.28));

  static List<BoxShadow> get soft => const [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
      ];

  /// The default card look: raised surface, hairline border, soft shadow.
  static BoxDecoration card({Color? color, bool shadow = true}) => BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: AppRadius.cardR,
        border: hairline,
        boxShadow: shadow ? soft : null,
      );

  /// A flatter, inset look for list rows / tiles.
  static BoxDecoration tile({Color? color}) => BoxDecoration(
        color: color ?? AppColors.overlay,
        borderRadius: AppRadius.cardR,
        border: hairline,
      );
}
