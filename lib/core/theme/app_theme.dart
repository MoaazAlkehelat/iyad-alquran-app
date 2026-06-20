import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {

  static ThemeData lightTheme =
  ThemeData(

    scaffoldBackgroundColor:
    AppColors.background,

    appBarTheme: const AppBarTheme(

      backgroundColor:
      AppColors.forestGreen,

      foregroundColor:
      Colors.white,
    ),
  );

  static ThemeData darkTheme =
  ThemeData.dark().copyWith(

    scaffoldBackgroundColor:
    Colors.black,

    appBarTheme: const AppBarTheme(

      backgroundColor:
      AppColors.forestGreen,
    ),
  );
}