import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/surah_model.dart';

class QuranService {
  static Future<List<Surah>> fetchSurahList() async {
    try {
      final response =
      await rootBundle.loadString('assets/database/surahs.json');

      final List data = json.decode(response);

      return data.map((e) => Surah.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Error loading surahs: $e');
    }
  }
}