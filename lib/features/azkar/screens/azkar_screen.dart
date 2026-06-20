import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import 'package:iyad_alquran/data/services/azkar_service.dart';
import 'zikr_details_screen.dart';

class AzkarScreen extends StatelessWidget {
  const AzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = AzkarService.getAzkar();

    final List<Color> tileColors = [
      const Color(0xFF13292A),
      const Color(0xFF1B3A3C),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B1516),

      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF0B1516),

        title: Text(
          "الأذكار",
          style: GoogleFonts.amiri(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),

        itemCount: categories.length,

        itemBuilder: (context, index) {
          final item = categories[index];

          return Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),

            decoration: BoxDecoration(
              color: tileColors[index % tileColors.length],

              borderRadius: BorderRadius.circular(22),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),

            child: Material(
              color: Colors.transparent,

              child: InkWell(
                borderRadius: BorderRadius.circular(22),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ZikrDetailsScreen(
                        category: item,
                      ),
                    ),
                  );
                },

                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),

                  child: Row(
                    children: [

                      /// أيقونة
                      Container(
                        width: 55,
                        height: 55,

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius:
                          BorderRadius.circular(18),
                        ),

                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.teal,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 16),

                      /// النص
                      Expanded(
                        child: Text(
                          item.category,
                          textDirection: TextDirection.rtl,

                          style: GoogleFonts.amiri(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// السهم
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.teal,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}