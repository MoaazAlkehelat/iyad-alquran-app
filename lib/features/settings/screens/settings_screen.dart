import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/services/app_state_service.dart';
import '../../../data/services/khatma_service.dart';

class SettingsScreen extends StatefulWidget {

  const SettingsScreen({
    super.key,
  });

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {

  bool isDarkMode = false;

  String username = '';

  @override
  void initState() {

    super.initState();

    loadData();
  }

  Future<void> loadData() async {

    final dark =
    await AppStateService.getDarkMode();

    final name =
    await AppStateService.getUsername();

    setState(() {

      isDarkMode = dark;

      username = name ?? '';
    });
  }

  Future<void> changeName() async {

    final controller =
    TextEditingController(
      text: username,
    );

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          backgroundColor:
          const Color(0xFF13292A),

          title: const Text(

            'تغيير الاسم',

            textDirection:
            TextDirection.rtl,

            style: TextStyle(
              color: Colors.white,
            ),
          ),

          content: TextField(

            controller: controller,

            textDirection:
            TextDirection.rtl,

            style: const TextStyle(
              color: Colors.white,
            ),
          ),

          actions: [

            ElevatedButton(

              onPressed: () async {

                final newName =
                controller.text.trim();

                if (newName.isEmpty) {
                  return;
                }

                await AppStateService
                    .saveUsername(
                  newName,
                );

                setState(() {

                  username = newName;
                });

                if (!mounted) return;

                Navigator.pop(context);
              },

              child: const Text(
                'حفظ',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildTile({

    required IconData icon,

    required String title,

    Widget? trailing,

    VoidCallback? onTap,
  }) {

    return Container(

      margin:
      const EdgeInsets.only(
        bottom: 14,
      ),

      decoration: BoxDecoration(

        color: AppColors.overlay,

        borderRadius:
        BorderRadius.circular(20),
      ),

      child: ListTile(

        onTap: onTap,

        leading: Icon(
          icon,
          color: AppColors.teal,
        ),

        trailing: trailing,

        title: Text(

          title,

          textDirection:
          TextDirection.rtl,

          style: GoogleFonts.cairo(

            color: Colors.white,

            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      AppColors.background,

      appBar: AppBar(

        backgroundColor:
        AppColors.background,

        elevation: 0,

        centerTitle: true,

        title: Text(

          'الإعدادات',

          style: GoogleFonts.amiri(

            color: Colors.white,

            fontSize: 28,

            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body: Padding(

        padding:
        const EdgeInsets.all(20),

        child: Column(

          children: [

            Container(

              padding:
              const EdgeInsets.all(
                20,
              ),

              decoration: BoxDecoration(

                color:
                AppColors.overlay,

                borderRadius:
                BorderRadius.circular(
                  24,
                ),
              ),

              child: Row(

                mainAxisAlignment:
                MainAxisAlignment.end,

                children: [

                  Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.end,

                    children: [

                      Text(

                        username,

                        textDirection:
                        TextDirection.rtl,

                        style:
                        GoogleFonts.amiri(

                          color:
                          Colors.white,

                          fontSize: 26,

                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(

                        'قارئ القرآن',

                        style:
                        GoogleFonts.cairo(

                          color:
                          Colors.white70,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    width: 14,
                  ),

                  CircleAvatar(

                    radius: 32,

                    backgroundColor:
                    AppColors.teal,

                    child: const Icon(

                      Icons.person,

                      color: Colors.black,

                      size: 34,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            buildTile(

              icon: Icons.person,

              title: 'تغيير الاسم',

              onTap: changeName,
            ),

            buildTile(

              icon: Icons.dark_mode,

              title: 'الوضع الليلي',

              trailing: Switch(

                value: isDarkMode,

                onChanged: (value) async {

                  setState(() {

                    isDarkMode = value;
                  });

                  await AppStateService
                      .saveDarkMode(
                    value,
                  );
                },
              ),
            ),

            buildTile(

              icon: Icons.auto_stories,

              title: 'إعادة الختمة',

              onTap: () async {

                await KhatmaService
                    .clearKhatma();

                if (!mounted) return;

                ScaffoldMessenger.of(
                    context)
                    .showSnackBar(

                  const SnackBar(

                    content: Text(
                      'تم حذف الختمة',
                    ),
                  ),
                );
              },
            ),

            buildTile(

              icon: Icons.info_outline,

              title: 'عن التطبيق',

              onTap: () {


                showAboutDialog(


                  context: context,

                  applicationName:
                  'إياد القرآن',

                  applicationVersion:
                  '1.0.0',

                  applicationIcon: Container(


                    padding:
                    const EdgeInsets.all(10),

                    decoration: BoxDecoration(

                      color: AppColors.teal,

                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                    ),

                    child: const Icon(

                      Icons.menu_book_rounded,

                      color: Colors.black,

                      size: 34,
                    ),
                  ),

                  children: [

                    const SizedBox(height: 14),

                    Text(

                      'إياد القرآن 🌿\n\n'
                          'تطبيق قرآني صُمم ليكون صدقة جارية '
                          'عن روح إياد النواجحة، '
                          'ورفيقًا يوميًا يساعد المسلم '
                          'على قراءة القرآن الكريم والأذكار '
                          'والدعاء بسهولة وطمأنينة.',

                      textDirection:
                      TextDirection.rtl,

                      style: GoogleFonts.cairo(

                        height: 1.8,

                        color: Colors.black87,
                      ),
                    ),
                  ],
                );
              },
            ),

            buildTile(

              icon: Icons.share,

              title: 'مشاركة التطبيق',

              onTap: () {

                Share.share(

                  'حمّل تطبيق إياد القرآن 🌿\n\n'
                      'رفيقك اليومي لقراءة القرآن والأذكار والدعاء.\n\n'
                      'https://your-app-link.com',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}