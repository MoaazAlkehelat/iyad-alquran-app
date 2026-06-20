import 'package:flutter/material.dart';
import 'package:iyad_alquran/core/constants/app_colors.dart';
import 'package:iyad_alquran/data/services/preferences_service.dart';
import 'package:iyad_alquran/data/models/bookmark_model.dart';
import 'package:iyad_alquran/data/services/app_state_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iyad_alquran/features/quran/surah_pages.dart';
import 'package:iyad_alquran/data/models/khatma_model.dart';
import 'package:iyad_alquran/data/services/khatma_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// تعريف عميل Supabase للوصول إليه داخل الشاشة
final supabase = Supabase.instance.client;

class ReaderScreen extends StatefulWidget {
  final String surahName;
  final int initialPage;

  const ReaderScreen({
    super.key,
    required this.surahName,
    required this.initialPage,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  KhatmaModel? khatma;
  int todayStart = 1;
  int todayEnd = 1;

  late final PageController _controller;
  int currentPage = 1;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage;

    // بما أن الـ PageView يبدأ من 0، والصفحات المصحف تبدأ من 1 إلى 604
    _controller = PageController(
      initialPage: widget.initialPage - 1,
    );

    loadTheme();
    loadKhatma();
  }

  // دالة جلب آيات الصفحة الحالية من Supabase
  Future<List<Map<String, dynamic>>> fetchPageVerses(int pageNumber) async {
    try {
      // جلب الآيات التي تنتمي لرقم الصفحة الحالي وترتيبها حسب الرقم التسلسلي للآية
      final response = await supabase
          .from('quran') // تأكد أن اسم الجدول في Supabase مطابق لملف قاعدة البيانات لديك
          .select('SURA, AYA_num, AYA')
          .eq('page_num', pageNumber) // تأكد من اسم عمود رقم الصفحة في جدولك (مثلاً page_num أو page)
          .order('SURA_num', ascending: true)
          .order('AYA_num', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("خطأ في جلب الآيات من سوبابيس: $e");
      return [];
    }
  }

  Future<void> loadKhatma() async {
    final data = await KhatmaService.getKhatma();
    if (data == null) return;

    setState(() {
      khatma = data;
      todayStart = KhatmaService.getTodayStartPage(data);
      todayEnd = KhatmaService.getTodayEndPage(data);
    });
  }

  final List<int> juzStarts = [
    1, 22, 42, 62, 82, 102, 122, 142, 162, 182,
    202, 222, 242, 262, 282, 302, 322, 342, 362, 382,
    402, 422, 442, 462, 482, 502, 522, 542, 562, 582,
  ];

  int getThePart(int page) {
    for (int i = juzStarts.length - 1; i >= 0; i--) {
      if (page >= juzStarts[i]) {
        return i + 1;
      }
    }
    return 1;
  }

  String getSurahName(int page) {
    SurahPage currentSurah = surahPages.first;
    for (final surah in surahPages) {
      if (surah.pageNumber <= page) {
        currentSurah = surah;
      } else {
        break;
      }
    }
    return currentSurah.surahName;
  }

  Future<void> loadTheme() async {
    final dark = await AppStateService.getDarkMode();
    setState(() {
      isDarkMode = dark;
    });
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
          Text(label, style: GoogleFonts.amiri(
              color: AppColors.blueGreen, fontSize: 18)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.background : const Color(0xFFFAF6EE),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statChip(getSurahName(currentPage), ""),
            _statChip(getThePart(currentPage).toString(), "الجزء"),
          ],
        ),
        actions: [
          // زر حفظ العلامة المرجعية (Bookmark)
          IconButton(
            onPressed: () {
              final controller = TextEditingController();
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF13292A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('اسم العلامة', textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white)),
                  content: TextField(
                    controller: controller,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'اكتب اسم العلامة',
                      hintTextDirection: TextDirection.rtl,
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF0B1819),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.teal),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.blueGreen, width: 2),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal, foregroundColor: Colors.black),
                      onPressed: () async {
                        final name = controller.text.trim();
                        if (name.isEmpty) return;

                        await PreferencesService.saveBookmark(
                          BookmarkModel(name: name, page: currentPage - 1),
                        );

                        if (!context.mounted) return;
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF13292A),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            content: const Text('تم حفظ العلامة بنجاح', textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white)),
                          ),
                        );
                      },
                      child: const Text('حفظ'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.bookmark),
          ),
          // زر التبديل بين الوضع الليلي والعادي
          IconButton(
            onPressed: () async {
              setState(() {
                isDarkMode = !isDarkMode;
              });
              await AppStateService.saveDarkMode(isDarkMode);
            },
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),

      // تغيير الـ PageView ليعرض نصوص الآيات بدلاً من الصور
      body: PageView.builder(
        controller: _controller,
        reverse: true, // للقراءة من اليمين إلى اليسار (القرآن الكريم)
        itemCount: 604, // إجمالي عدد صفحات المصحف الشريف
        onPageChanged: (page) async {
          await AppStateService.saveLastPage(page);
          await AppStateService.saveDarkMode(isDarkMode);

          if (khatma != null) {
            final updated = KhatmaModel(
              dailyPages: khatma!.dailyPages,
              startPage: khatma!.startPage,
              currentPage: page + 1,
              startDate: khatma!.startDate,
              completed: page + 1 >= 604,
            );
            await KhatmaService.saveKhatma(updated);
          }

          setState(() {
            currentPage = page + 1;
          });
        },
        itemBuilder: (context, index) {
          final pageNum = index + 1;

          // استخدام FutureBuilder لجلب آيات هذه الصفحة المحددة من Supabase
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchPageVerses(pageNum),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.teal));
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'تعذر تحميل آيات هذه الصفحة أو تأكد من اتصال الإنترنت.',
                    style: TextStyle(fontFamily: 'Amiri', fontSize: 18),
                    textDirection: TextDirection.rtl,
                  ),
                );
              }

              final verses = snapshot.data!;

              // تجميع كافة نصوص الآيات داخل نص واحد متصل لعرضها كمصحف حقيقي
              List<InlineSpan> textSpans = [];
              for (var verse in verses) {
                final String text = verse['AYA'] ?? '';
                final int number = verse['AYA_num'] ?? 0;

                textSpans.add(
                  TextSpan(
                    text: '$text ',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 22,
                      height: 2.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );

                // إضافة رقم الآية بشكل متميز (بين قوسين أو رمز مصحف)
                textSpans.add(
                  TextSpan(
                    text: '﴿$number﴾ ',
                    style: const TextStyle(
                      color: AppColors.teal,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      //fontFamily: 'Amiri', // تأكد من إضافة خط أميري أو الخط العثماني في pubspec.yaml
                      children: textSpans,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

      bottomNavigationBar: Container(
        height: 55,
        alignment: Alignment.center,
        color: AppColors.forestGreen,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'الصفحة $currentPage',
              style: const TextStyle(color: Colors.white),
            ),
            if (khatma != null)
              Text(
                'ورد اليوم: $todayStart - $todayEnd',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}