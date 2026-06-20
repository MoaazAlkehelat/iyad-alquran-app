import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iyad_alquran/core/constants/app_colors.dart';
import 'package:iyad_alquran/data/models/surah_model.dart';
import 'package:iyad_alquran/data/services/quran_service.dart';
import 'package:iyad_alquran/core/theme/app_theme.dart';
import '../widgets/surah_card.dart';
import 'reader_screen.dart';
import 'package:iyad_alquran/features/quran/surah_pages.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Surah> _allSurahs = [];
  List<Surah> _filtered = [];

  bool _loading = true;
  String? _error;

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_onSearch);
  }
  int getSurahPage(String surahName) {
    final result = surahPages.firstWhere(
          (s) => s.surahName == surahName,
      orElse: () =>
          SurahPage(
            surahName: '',
            pageNumber: 15,
          ),
    );


    return result.pageNumber;
  }
  String normalizeArabic(String text) {

    return text

    // Remove Harakat
        .replaceAll(
      RegExp(r'[\u064B-\u065F\u0670]'),
      '',
    )

    // Remove Tatweel
        .replaceAll('ـ', '')

    // Normalize Alef
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')

    // Normalize Ya
        .replaceAll('ى', 'ي')

    // Normalize Ta Marbuta
        .replaceAll('ة', 'ه')

        .toLowerCase();
  }

  Future<void> _load() async {
    try {
      final list = await QuranService.fetchSurahList();

      print("SUCCESS: ${list.length}");

      setState(() {
        _allSurahs = list;
        _filtered = list;
        _loading = false;
      });
    } catch (e) {
      print("❌ REAL ERROR: $e");

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onSearch() {

    final q = _searchCtrl.text;

    setState(() {

      _filtered =
          _allSurahs.where((surah) {

            final normalizedSurah =
            normalizeArabic(
              surah.nameArabic,
            );

            final normalizedQuery =
            normalizeArabic(q);

            return normalizedSurah
                .contains(normalizedQuery);

          }).toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildStats(),
            SizedBox(height: 10,),


            Expanded(
              child: _loading
                  ? const _LoadingView()
                  : _error != null
                  ? _ErrorView(
                error: _error!,
                onRetry: _load,
              )
                  : _buildList(),
            ),
          ],
        ),
      ),
    );
  }
  Widget _statChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.teal.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: GoogleFonts.lato(
              color: AppColors.teal, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.lato(
              color: AppColors.blueGreen, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Center(
            child: Text(
              'ابحث في القرآن الكريم',
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiri(
                fontSize: 30,
                color: AppColors.spearmint,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              'ابحث باسم السورة أو رقمها',
              textDirection: TextDirection.rtl,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppColors.blueGreen,
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.spearmint,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.teal.withOpacity(0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchCtrl,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: 'ابحث عن سورة...',
            hintTextDirection: TextDirection.rtl,
            hintStyle: GoogleFonts.cairo(
              color: AppColors.background.withOpacity(0.6),
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.background,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ).animate().fadeIn(delay: 200.ms),
    );
  }
  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(

        children: [

      _statChip( '114','السور'),
          const SizedBox(width: 12),
          _statChip( '6236','الآيات'),
          const SizedBox(width: 12),
          _statChip( '30','الأجزاء'),

        ],
      ),
    );
  }
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF18392B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.teal.withOpacity(0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.teal,
            size: 24,
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: GoogleFonts.cairo(
              color: AppColors.blueGreen,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      itemCount: _filtered.length,
      itemBuilder: (context, index) {
        final surah = _filtered[index];

        final bool isEven = index % 2 == 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          child: Material(
            color: isEven
                ? AppColors.forestGreen
                : AppColors.forestGreen.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReaderScreen(
                      surahName: surah.nameArabic,
                      initialPage: getSurahPage(surah.nameArabic),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.teal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          surah.id.toString(),
                          style: GoogleFonts.cairo(
                            color: AppColors.teal,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            surah.nameArabic,
                            textDirection: TextDirection.rtl,
                            style: GoogleFonts.amiri(
                              color: AppColors.spearmint,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '${surah.totalVerses} آية',
                            textDirection: TextDirection.rtl,
                            style: GoogleFonts.cairo(
                              color: AppColors.blueGreen,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.teal,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(
          delay: Duration(milliseconds: 50 * index),
          duration: 350.ms,
        )
            .slideY(begin: 0.2, end: 0);
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.teal,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.teal,
              size: 60,
            ),

            const SizedBox(height: 14),

            Text(
              'حدث خطأ أثناء تحميل السور',
              textDirection: TextDirection.rtl,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: AppColors.forestGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'إعادة المحاولة',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}