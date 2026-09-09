import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How the reader lays out pages: one continuous vertical scroll, or a
/// horizontal page-by-page "flip" (like a physical mushaf).
enum ReaderLayout { vertical, horizontal }

/// App-wide user settings shared live across every screen (dark mode + reading
/// typography). Replaces the old pattern where each screen read SharedPreferences
/// in its own initState and never heard about later changes.
class AppSettings extends ChangeNotifier {
  static const _darkKey = 'dark_mode';
  static const _fontScaleKey = 'reading_font_scale';
  static const _lineHeightKey = 'reading_line_height';
  static const _readerLayoutKey = 'reader_layout';

  bool _isDarkMode = false;
  double _readingFontScale = 1.0;
  double _lineHeight = 2.1;
  ReaderLayout _readerLayout = ReaderLayout.vertical;

  bool get isDarkMode => _isDarkMode;
  double get readingFontScale => _readingFontScale;
  double get lineHeight => _lineHeight;
  ReaderLayout get readerLayout => _readerLayout;

  static const double minFontScale = 0.8;
  static const double maxFontScale = 1.8;
  static const double minLineHeight = 1.8;
  static const double maxLineHeight = 2.6;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkKey) ?? false;
    _readingFontScale =
        (prefs.getDouble(_fontScaleKey) ?? 1.0).clamp(minFontScale, maxFontScale);
    _lineHeight =
        (prefs.getDouble(_lineHeightKey) ?? 2.1).clamp(minLineHeight, maxLineHeight);
    final layoutName = prefs.getString(_readerLayoutKey);
    _readerLayout = ReaderLayout.values.firstWhere(
      (l) => l.name == layoutName,
      orElse: () => ReaderLayout.vertical,
    );
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, value);
  }

  Future<void> toggleDarkMode() => setDarkMode(!_isDarkMode);

  Future<void> setReadingFontScale(double value) async {
    final v = value.clamp(minFontScale, maxFontScale);
    if (_readingFontScale == v) return;
    _readingFontScale = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, v);
  }

  Future<void> bumpFontScale(double delta) =>
      setReadingFontScale(_readingFontScale + delta);

  Future<void> setLineHeight(double value) async {
    final v = value.clamp(minLineHeight, maxLineHeight);
    if (_lineHeight == v) return;
    _lineHeight = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lineHeightKey, v);
  }

  Future<void> setReaderLayout(ReaderLayout value) async {
    if (_readerLayout == value) return;
    _readerLayout = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_readerLayoutKey, value.name);
  }
}
