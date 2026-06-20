import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

import '../../features/quran/screens/surah_list_screen.dart';
import '../../data/dashboard/screens/dashboard_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/bookmarks/screens/bookmarks_screen.dart';
import '../../features/quran/screens/search_screen.dart';

class ShellScreen extends StatefulWidget {

  const ShellScreen({
    super.key,
  });

  @override
  State<ShellScreen> createState() =>
      _ShellScreenState();
}

class _ShellScreenState
    extends State<ShellScreen> {

  int currentIndex = 0;

  final screens = [

    const DashboardScreen(),

    const SearchScreen(),

    const BookmarksScreen(),

    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: screens[currentIndex],

      bottomNavigationBar:
      BottomNavigationBar(

        currentIndex: currentIndex,

        onTap: (index) {

          setState(() {

            currentIndex = index;
          });
        },

        backgroundColor:
        const Color(0xFF0B1819),

        selectedItemColor:
        AppColors.teal,

        unselectedItemColor:
        AppColors.blueGreen,

        type:
        BottomNavigationBarType
            .fixed,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'القرأن',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'البحث',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'العلامات المرجعية',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'الأعدادات',
          ),
        ],
      ),
    );
  }
}