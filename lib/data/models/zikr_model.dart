class ZikrModel {
  final int id;
  final String text;
  final int count;

  // موجودين بالـ JSON لكن لن نستخدمهم
  final String? audio;
  final String? filename;

  ZikrModel({
    required this.id,
    required this.text,
    required this.count,
    this.audio,
    this.filename,
  });

  factory ZikrModel.fromJson(Map<String, dynamic> json) {
    return ZikrModel(
      id: json['id'],
      text: json['text'],
      count: json['count'],
      audio: json['audio'],
      filename: json['filename'],
    );
  }
}