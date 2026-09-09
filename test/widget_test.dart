import 'package:flutter_test/flutter_test.dart';
import 'package:iyad_alquran/core/utils/arabic.dart';

void main() {
  test('toArabicDigits converts western digits only', () {
    expect(toArabicDigits(604), '٦٠٤');
    expect(toArabicDigits('صفحة 42'), 'صفحة ٤٢');
  });

  test('normalizeArabic is harakat / spelling tolerant', () {
    expect(normalizeArabic('الْحَمْدُ'), normalizeArabic('الحمد'));
    expect(normalizeArabic('إنّ'), normalizeArabic('ان'));
    expect(normalizeArabic('رحمةٌ'), normalizeArabic('رحمه'));
  });
}
