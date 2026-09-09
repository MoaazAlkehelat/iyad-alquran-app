import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/dashboard/screens/dashboard_screen.dart';
import '../../features/bookmarks/screens/bookmarks_screen.dart';
import '../../features/quran/screens/search_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int currentIndex = 0;

  static const _screens = [
    DashboardScreen(),
    SearchScreen(),
    BookmarksScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps every tab mounted so switching doesn't rebuild the
      // screen, re-run its futures, or lose scroll position.
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.teal,
        unselectedItemColor: AppColors.blueGreen,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'القرآن'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'البحث'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark), label: 'العلامات المرجعية'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
      ),
    );
  }
}
