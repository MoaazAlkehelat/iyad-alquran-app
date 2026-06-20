import 'dart:convert';

import '../../../data/models/azkar_category_model.dart';
import '../../../data/sources/azkar_data.dart';

class AzkarService {
  static List<AzkarCategoryModel> getAzkar() {
    final decoded = jsonDecode(azkarJson);

    return (decoded as List)
        .map((e) => AzkarCategoryModel.fromJson(e))
        .toList();
  }
}