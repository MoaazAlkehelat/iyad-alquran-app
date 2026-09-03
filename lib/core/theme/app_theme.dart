import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  // A flat app bar that never tints darker when content scrolls under it.
  static const _appBar = AppBarTheme(
    backgroundColor: AppColors.forestGreen,
    foregroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
  );

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: _appBar,
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: _appBar,
  );
}
