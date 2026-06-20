import 'package:flutter/material.dart';
import 'package:iyad_alquran/navigation/screens/shell_screen.dart';
import 'package:iyad_alquran/data/dashboard/screens/dashboard_screen.dart';
import 'core/theme/app_theme.dart';
import 'features/quran/screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://phfqbtmrskfzahnvkghu.supabase.co',
    anonKey: 'sb_publishable_j-dMlLyGrkj76SYItHswQQ_3kbv_lNJ',
  );

  runApp(const IyadQuranApp());
}

final supabase = Supabase.instance.client;

class IyadQuranApp extends StatelessWidget {
  const IyadQuranApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'Iyad Quran',

      theme: AppTheme.lightTheme,

      darkTheme: AppTheme.darkTheme,

      home: const ShellScreen(),
    );
  }
}