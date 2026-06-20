import 'package:flutter/material.dart';
import 'package:iyad_alquran/core/constants/app_colors.dart';
import 'package:iyad_alquran/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/azkar_category_model.dart';

class ZikrDetailsScreen extends StatefulWidget {
  final AzkarCategoryModel category;

  const ZikrDetailsScreen({
    super.key,
    required this.category,
  });

  @override
  State<ZikrDetailsScreen> createState() => _ZikrDetailsScreenState();
}

class _ZikrDetailsScreenState extends State<ZikrDetailsScreen> {
  late List<int> currentCounts;

  @override
  void initState() {
    super.initState();

    currentCounts = widget.category.azkar
        .map((e) => e.count)
        .toList();
  }

  void decrement(int index) {
    if (currentCounts[index] > 0) {
      setState(() {
        currentCounts[index]--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.category,style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.category.azkar.length,

        itemBuilder: (context, index) {
          final zikr = widget.category.azkar[index];

          final remaining = currentCounts[index];

          final progress =
              (zikr.count - remaining) / zikr.count;

          return Container(
            margin: const EdgeInsets.only(bottom: 20),

            decoration: BoxDecoration(
              color: AppColors.forestGreen,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  /// الذكر
                  Text(
                    zikr.text,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.amiri(
                      height: 2,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                      letterSpacing: 0,
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// Progress
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      color: AppColors.teal,
                      value: progress,
                      minHeight: 10,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [

                      /// العدد المتبقي
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),

                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(18),
                          color: AppColors.teal
                              .withOpacity(0.12),
                        ),

                        child: Text(
                          "$remaining / ${zikr.count}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                            Colors.white,
                          ),
                        ),
                      ),

                      /// زر التسبيح
                      ElevatedButton(
                        onPressed: remaining == 0
                            ? null
                            : () => decrement(index),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal.withOpacity(0.12),

                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(18),
                          ),
                        ),

                        child: Text(
                          remaining == 0
                              ? "تم ✓"
                              : "تسبيح",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}