import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:iyad_alquran/data/models/bookmark_model.dart';

class PreferencesService {

  static const bookmarksKey =
      'bookmarks';

  static Future<void>
  saveBookmark(
      BookmarkModel bookmark,
      ) async {

    final prefs =
    await SharedPreferences
        .getInstance();

    final bookmarks =
    await getBookmarks();

    bookmarks.add(bookmark);

    final encoded = bookmarks
        .map((e) => jsonEncode(
      e.toMap(),
    ))
        .toList();

    await prefs.setStringList(
      bookmarksKey,
      encoded,
    );
  }

  static Future<List<BookmarkModel>>
  getBookmarks() async {

    final prefs =
    await SharedPreferences
        .getInstance();

    final data =
        prefs.getStringList(
          bookmarksKey,
        ) ??
            [];

    return data.map((e) {

      return BookmarkModel.fromMap(
        jsonDecode(e),
      );
    }).toList();
  }

  static Future<void>
  deleteBookmark(
      int index,
      ) async {

    final prefs =
    await SharedPreferences
        .getInstance();

    final bookmarks =
    await getBookmarks();

    bookmarks.removeAt(index);

    final encoded = bookmarks
        .map((e) => jsonEncode(
      e.toMap(),
    ))
        .toList();

    await prefs.setStringList(
      bookmarksKey,
      encoded,
    );
  }
}