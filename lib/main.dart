import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/state/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'navigation/screens/shell_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = AppSettings();
  await settings.load();

  runApp(
    ChangeNotifierProvider.value(
      value: settings,
      child: const IyadQuranApp(),
    ),
  );
}

class IyadQuranApp extends StatelessWidget {
  const IyadQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Iyad Quran',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        // Clamp OS font scaling so fixed-size rows can't blow out, while still
        // honouring accessibility settings within reason.
        final mq = MediaQuery.of(context);
        final clamped = mq.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.3,
        );
        return MediaQuery(
          data: mq.copyWith(textScaler: clamped),
          child: child!,
        );
      },
      home: const ShellScreen(),
    );
  }
}
