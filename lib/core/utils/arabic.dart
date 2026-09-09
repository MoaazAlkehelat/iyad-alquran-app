// Arabic text helpers shared across search and the reader.

const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

/// Converts Western digits in [input] to Arabic-Indic digits.
String toArabicDigits(Object input) {
  final s = input.toString();
  final buffer = StringBuffer();
  for (final ch in s.runes) {
    if (ch >= 0x30 && ch <= 0x39) {
      buffer.write(_arabicDigits[ch - 0x30]);
    } else {
      buffer.writeCharCode(ch);
    }
  }
  return buffer.toString();
}

/// Strips harakat/tatweel and normalizes alef/ya/ta-marbuta so search is
/// tolerant of how the user types. Also drops the Quranic small marks used in
/// the Uthmani script so typed plain Arabic still matches.
String normalizeArabic(String text) {
  return text
      // Harakat + Quranic annotation signs (U+0610–U+061A, U+064B–U+065F, U+0670, U+06D6–U+06ED)
      .replaceAll(RegExp(r'[ؐ-ًؚ-ٰٟۖ-ۭ]'), '')
      // Tatweel
      .replaceAll('ـ', '')
      // Alef variants
      .replaceAll(RegExp(r'[إأآٱ]'), 'ا')
      // Ya / Alef maqsura
      .replaceAll('ى', 'ي')
      // Ta marbuta
      .replaceAll('ة', 'ه')
      // Hamza on the line
      .replaceAll('ء', '')
      .trim();
}
