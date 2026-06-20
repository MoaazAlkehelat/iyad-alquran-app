import 'zikr_model.dart';

class AzkarCategoryModel {
  final int id;
  final String category;

  // موجودين فقط للمحافظة على structure
  final String? audio;
  final String? filename;

  final List<ZikrModel> azkar;

  AzkarCategoryModel({
    required this.id,
    required this.category,
    required this.azkar,
    this.audio,
    this.filename,
  });

  factory AzkarCategoryModel.fromJson(Map<String, dynamic> json) {
    return AzkarCategoryModel(
      id: json['id'],
      category: json['category'],
      audio: json['audio'],
      filename: json['filename'],
      azkar: (json['array'] as List)
          .map((e) => ZikrModel.fromJson(e))
          .toList(),
    );
  }
}