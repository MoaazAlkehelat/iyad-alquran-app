import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/surah_model.dart';

class SurahCard extends StatelessWidget {

  final Surah surah;

  final VoidCallback onTap;

  const SurahCard({
    super.key,
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        margin:
        const EdgeInsets.only(
          bottom: 16,
        ),

        padding:
        const EdgeInsets.all(18),

        decoration: BoxDecoration(

          color: AppColors.forestGreen,

          borderRadius:
          BorderRadius.circular(
            18,
          ),

          border: Border.all(
            color: AppColors.teal
                .withOpacity(0.25),
          ),
        ),

        child: Row(
          children: [

            Container(

              width: 52,
              height: 52,

              alignment:
              Alignment.center,

              decoration: BoxDecoration(

                color: AppColors.teal
                    .withOpacity(0.15),

                shape: BoxShape.circle,
              ),

              child: Text(

                '${surah.id}',

                style:
                GoogleFonts.poppins(

                  color:
                  AppColors.teal,

                  fontWeight:
                  FontWeight.bold,

                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [

                  Text(

                    surah.nameArabic,

                    textDirection:
                    TextDirection.rtl,

                    style:
                    GoogleFonts.amiri(

                      fontSize: 28,

                      color: Colors.white,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(

                    surah.nameEnglish,

                    style:
                    GoogleFonts.poppins(

                      color: AppColors
                          .blueGreen,

                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.teal,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}