class Surah {
  final int id;
  final String nameArabic;
  final String nameEnglish;
  final String revelationType;
  final int totalVerses;
  final int order;

  Surah({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    required this.revelationType,
    required this.totalVerses,
    required this.order,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json['id'],
      nameArabic: json['name_arabic'],
      nameEnglish: json['name_english'],
      revelationType: json['revelation_type'],
      totalVerses: json['total_verses'],
      order: json['order'],
    );
  }
}