import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import 'package:iyad_alquran/features/dua/screens/dua_screen.dart';
import 'package:iyad_alquran/features/azkar/screens/azkar_screen.dart';
import 'package:iyad_alquran/data/models/khatma_model.dart';
import 'package:iyad_alquran/data/services/khatma_service.dart';
import 'package:iyad_alquran/data/services/app_state_service.dart';
import '../../../features/quran/screens/reader_screen.dart';
import '../../quran/surah_names.dart';

class DashboardScreen
    extends StatefulWidget {

  const DashboardScreen({
    super.key,
  });

  @override
  State<DashboardScreen>
  createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {

  KhatmaModel? khatma;
  bool loadingKhatma = true;
  int todayStart = 1;
  int todayEnd = 1;

  String? username;

  int lastPage = 0;

  final controller =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    loadData();
    loadKhatma();
  }
  Future<void> loadKhatma() async {

    final data =
    await KhatmaService.getKhatma();

    if (data != null) {

      todayStart =
          KhatmaService.getTodayStartPage(
              data);

      todayEnd =
          KhatmaService.getTodayEndPage(
              data);
    }

    setState(() {

      khatma = data;

      loadingKhatma = false;
    });
  }
  void showCreateKhatmaDialog() {

    final controller =
    TextEditingController();

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          backgroundColor:
          const Color(0xFF13292A),

          shape: RoundedRectangleBorder(

            borderRadius:
            BorderRadius.circular(20),
          ),

          title: const Text(

            'عدد الصفحات يوميًا',

            textDirection:
            TextDirection.rtl,

            style: TextStyle(
              color: Colors.white,
            ),
          ),

          content: TextField(

            controller: controller,

            keyboardType:
            TextInputType.number,

            textDirection:
            TextDirection.rtl,

            style: const TextStyle(
              color: Colors.white,
            ),

            decoration: InputDecoration(

              hintText: 'مثال: 20',

              hintTextDirection:
              TextDirection.rtl,

              hintStyle:
              const TextStyle(
                color: Colors.white54,
              ),

              filled: true,

              fillColor:
              const Color(0xFF0B1819),

              enabledBorder:
              OutlineInputBorder(

                borderRadius:
                BorderRadius.circular(
                  14,
                ),

                borderSide:
                const BorderSide(
                  color: AppColors.teal,
                ),
              ),

              focusedBorder:
              OutlineInputBorder(

                borderRadius:
                BorderRadius.circular(
                  14,
                ),

                borderSide:
                const BorderSide(
                  color: AppColors.blueGreen,
                  width: 2,
                ),
              ),
            ),
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(context);
              },

              child: const Text(

                'إلغاء',

                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),

            ElevatedButton(

              style:
              ElevatedButton.styleFrom(

                backgroundColor:
                AppColors.teal,

                foregroundColor:
                Colors.black,
              ),

              onPressed: () async {

                final pages =
                int.tryParse(
                    controller.text);

                if (pages == null ||
                    pages <= 0) {
                  return;
                }

                final newKhatma =
                KhatmaModel(

                  dailyPages: pages,

                  startPage: 1,

                  currentPage: 1,

                  startDate:
                  DateTime.now(),

                  completed: false,
                );

                await KhatmaService
                    .saveKhatma(
                    newKhatma);

                if (!mounted) return;

                Navigator.pop(context);

                loadKhatma();
              },

              child: Text(

                'حفظ',
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> loadData() async {

    final savedName =
    await AppStateService
        .getUsername();

    final page =
    await AppStateService
        .getLastPage();

    setState(() {

      username = savedName;

      lastPage = page;
    });

    if (savedName == null) {

      askName();
    }
  }

  void askName() {

    Future.delayed(
      Duration.zero,
          () {

        showDialog(

          context: context,

          barrierDismissible:
          false,

          builder: (_) {

            return AlertDialog(

              backgroundColor:
              const Color(
                0xFF13292A,
              ),

              title: const Text(

                'ما اسمك؟',

                textDirection:
                TextDirection.rtl,

                style: TextStyle(
                  color: Colors.white,
                ),
              ),

              content: TextField(
                decoration: InputDecoration(
                  focusColor: AppColors.background
                ),

                controller:
                controller,

                textDirection:
                TextDirection.rtl,

                style:
                const TextStyle(
                  color:
                  Colors.white,
                ),
              ),

              actions: [

                ElevatedButton(

                  onPressed:
                      () async {

                    final name =
                    controller
                        .text
                        .trim();

                    if (name
                        .isEmpty) {
                      return;
                    }

                    await AppStateService
                        .saveUsername(
                      name,
                    );

                    setState(() {

                      username =
                          name;
                    });

                    if (!context
                        .mounted) {
                      return;
                    }

                    Navigator.pop(
                      context,
                    );
                  },

                  child: const Text(
                    style: TextStyle(color: AppColors.teal),
                    'حفظ',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFF13292A,
      ),

      body: SafeArea(

        child: SingleChildScrollView(

          physics: const BouncingScrollPhysics(),

          child: Padding(

            padding: const EdgeInsets.all(20),

            child: Column(

            crossAxisAlignment:
            CrossAxisAlignment
                .center,

            children: [

              const SizedBox(
                height: 30,
              ),

              Text(

                'إياد القرآن • رفيقك إلى كتاب الله ',
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  color: AppColors.blueGreen,
                  letterSpacing: 0,
              ),),

              const SizedBox(
                height: 8,
              ),

              Directionality(

                textDirection: TextDirection.rtl,

                child: Row(
                children: [
                  Text(


                    username ?? '',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.amiri(
                      fontSize: 36,
                      color: Colors.white,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
              ),

              const SizedBox(
                height: 20,
              ),

              Container(

                padding:
                const EdgeInsets
                    .all(18),

                decoration:
                BoxDecoration(

                  color: const Color(0xFF0B1819),

                  borderRadius:
                  BorderRadius
                      .circular(
                    24,
                  ),
                ),

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment
                      .end,

                  children: [

                     Text(

                      'آخر قراءة',

                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.amiri(
                        fontSize: 18,
                        color: Colors.white,
                        letterSpacing: 0,
                      ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    Text(

                      'الصفحة ${lastPage + 1}',

                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.amiri(
                        fontSize: 24,
                        color: Colors.white,
                        letterSpacing: 0,
                        fontWeight: FontWeight.bold
                      ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    Text(

                      surahNames[1] ??
                          '',

                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.amiri(
                        fontSize: 18,
                        color: AppColors.blueGreen,
                        letterSpacing: 0,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    SizedBox(

                      width:
                      double.infinity,

                      child:
                      ElevatedButton(

                        style:
                        ElevatedButton
                            .styleFrom(

                          backgroundColor:
                          AppColors
                              .teal,

                          foregroundColor:
                          Colors
                              .black,


                        ),

                        onPressed:
                            () {

                              Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder: (_) => ReaderScreen(

                                    surahName: '',
                                    initialPage: lastPage,
                                  ),
                                ),
                              );
                        },

                        child:  Text(

                          'أكمل القراءة',
                            textDirection: TextDirection.rtl,
                            style: GoogleFonts.amiri(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 0,
                            )
                        ),
                      ),
                    ),

                  ],
                ),
              ),
              SizedBox(height: 20,),
              GestureDetector(

                onTap: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                      const DuaScreen(),
                    ),
                  );
                },

                child: Container(

                  width: double.infinity,

                  padding:
                  const EdgeInsets.all(22),

                  decoration: BoxDecoration(

                    color:  AppColors.background,

                    borderRadius:
                    BorderRadius.circular(
                      24,
                    ),

                    border: Border.all(

                      color:
                      AppColors.teal
                          .withOpacity(0.2),
                    ),
                  ),

                  child: Row(

                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                    children: [

                      const Icon(

                        Icons.favorite,

                        color:
                        AppColors.teal,

                        size: 30,
                      ),

                      Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.end,

                        children: [

                          const Text(

                            'دعاء للميت',

                            textDirection:
                            TextDirection.rtl,

                            style: TextStyle(

                              color:
                              Colors.white,

                              fontSize: 22,

                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Text(

                            'رحمةٌ ودعاءٌ لمن نحب',

                            textDirection:
                            TextDirection.rtl,

                            style: TextStyle(

                              color:
                              Colors.white
                                  .withOpacity(
                                0.7,
                              ),

                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20,),
              GestureDetector(

                onTap: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                      const AzkarScreen(),
                    ),
                  );
                },

                child: Container(

                  width: double.infinity,

                  padding:
                  const EdgeInsets.all(22),

                  decoration: BoxDecoration(

                    color:  AppColors.background,

                    borderRadius:
                    BorderRadius.circular(
                      24,
                    ),

                    border: Border.all(

                      color:
                      AppColors.teal
                          .withOpacity(0.2),
                    ),
                  ),

                  child: Row(

                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                    children: [

                      const Icon(


                            Icons.menu_book_rounded,
                            color: AppColors.teal,
                            size: 30,

                      ),

                      Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.end,

                        children: [

                          const Text(

                            'الأذكار',

                            textDirection:
                            TextDirection.rtl,

                            style: TextStyle(

                              color:
                              Colors.white,

                              fontSize: 22,

                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Text(

                            'الا بذكر الله تطمئن القلوب',

                            textDirection:
                            TextDirection.rtl,

                            style: TextStyle(

                              color:
                              Colors.white
                                  .withOpacity(
                                0.7,
                              ),

                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (loadingKhatma)

                const Center(
                  child: CircularProgressIndicator(),
                )

              else if (khatma == null)

                Container(
                  height: 240,


                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(

                    color: AppColors.overlay,

                    borderRadius:
                    BorderRadius.circular(24),

                    border: Border.all(
                      color: AppColors.teal
                          .withOpacity(0.2),
                    ),
                  ),

                  child: Column(

                    children: [

                      Icon(
                        Icons.menu_book_rounded,
                        size: 45,
                        color: AppColors.teal,
                      ),

                      const SizedBox(height: 14),

                      Text(

                        'ابدأ ختمتك القرآنية',

                        style: GoogleFonts.amiri(

                          fontSize: 24,

                          color: Colors.white,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(

                        'حدد وردك اليومي وابدأ رحلتك مع القرآن',

                        textAlign: TextAlign.center,

                        style: GoogleFonts.cairo(

                          color: Colors.white70,

                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 18),

                      ElevatedButton(

                        style: ElevatedButton.styleFrom(

                          backgroundColor:
                          AppColors.teal,

                          foregroundColor:
                          Colors.black,

                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 12,
                          ),
                        ),

                        onPressed: () {

                          showCreateKhatmaDialog();
                        },

                        child: const Text(
                          'ابدأ الختمة',
                        ),
                      ),
                    ],
                  ),
                )

              else

                Container(

                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(

                    color: AppColors.background,

                    borderRadius:
                    BorderRadius.circular(24),

                    border: Border.all(
                      color: AppColors.teal
                          .withOpacity(0.2),
                    ),
                  ),

                  child: Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.center,

                    children: [

                      Row(

                        children: [

                          Icon(
                            Icons.auto_stories,
                            color: AppColors.teal,
                          ),

                          const SizedBox(width: 8),

                          Text(

                            'الختمة الحالية',

                            style: GoogleFonts.amiri(

                              fontSize: 22,

                              color: Colors.white,

                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Text(

                        'ورد اليوم: '
                            '$todayStart - $todayEnd',

                        style: GoogleFonts.cairo(

                          color: Colors.white70,

                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(

                        'الصفحة الحالية: '
                            '${khatma!.currentPage}',

                        style: GoogleFonts.cairo(

                          color: Colors.white70,

                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 18),

                      ClipRRect(

                        borderRadius:
                        BorderRadius.circular(20),

                        child: LinearProgressIndicator(
                            color: AppColors.teal,
                          minHeight: 10,

                          value:
                          khatma!.currentPage / 604,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Align(

                        alignment: Alignment.centerLeft,

                        child: Text(

                          '${((khatma!.currentPage / 604) * 100).toInt()}%',

                          style: GoogleFonts.cairo(

                            color: Colors.white60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],

          ),
        ),
      ),
      ),
    );
  }
}