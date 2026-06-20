import 'package:flutter/material.dart';

class DuaScreen
    extends StatelessWidget {

  const DuaScreen({
    super.key,
  });

  final List<String> duas = const [

    'اللَّهُمَّ اغْفِرْ لَهُ وَارْحَمْهُ وَعَافِهِ وَاعْفُ عَنْهُ.',

    'اللَّهُمَّ اجْعَلْ قَبْرَهُ رَوْضَةً مِنْ رِيَاضِ الْجَنَّةِ.',

    'اللَّهُمَّ آنِسْهُ فِي وَحْدَتِهِ وَفِي وَحْشَتِهِ.',

    'اللَّهُمَّ اجْعَلِ الْقُرْآنَ شَفِيعًا لَهُ يَوْمَ الْقِيَامَةِ.',

    'اللَّهُمَّ نَوِّرْ لَهُ قَبْرَهُ وَوَسِّعْ مُدْخَلَهُ.',

    'اللَّهُمَّ ارْحَمْ مَوْتَانَا وَمَوْتَى الْمُسْلِمِينَ.',

    'اللَّهُمَّ اجْعَلْ مَثْوَاهُ الْفِرْدَوْسَ الْأَعْلَى.',

    'اللَّهُمَّ اغْسِلْهُ بِالْمَاءِ وَالثَّلْجِ وَالْبَرَدِ.',

    'اللَّهُمَّ اجْعَلْ أَعْمَالَهُ الصَّالِحَةَ نُورًا لَهُ.',

    'اللَّهُمَّ ارْزُقْ أَهْلَهُ الصَّبْرَ وَالسَّكِينَةَ.',
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(
        0xFF0B1819,
      ),

      appBar: AppBar(

        backgroundColor:
        const Color(
          0xFF13292A,
        ),

        title: const Text(
          'دعاء للميت',
        ),

        centerTitle: true,
      ),

      body: ListView.builder(

        padding:
        const EdgeInsets.all(
          20,
        ),

        itemCount: duas.length,

        itemBuilder:
            (context, index) {

          return Container(

            margin:
            const EdgeInsets.only(
              bottom: 18,
            ),

            padding:
            const EdgeInsets.all(
              22,
            ),

            decoration:
            BoxDecoration(

              color: const Color(
                0xFF13292A,
              ),

              borderRadius:
              BorderRadius.circular(
                24,
              ),

              border: Border.all(

                color:
                const Color(
                  0xFF499FA4,
                ).withOpacity(0.2),
              ),
            ),

            child: Text(

              duas[index],

              textDirection:
              TextDirection.rtl,

              style:
              const TextStyle(

                color: Colors.white,

                height: 2,

                fontSize: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}