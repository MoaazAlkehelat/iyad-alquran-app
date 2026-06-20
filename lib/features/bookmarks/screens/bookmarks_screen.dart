import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

import 'package:iyad_alquran/data/models/bookmark_model.dart';

import 'package:iyad_alquran/data/services/preferences_service.dart';

import '../../quran/screens/reader_screen.dart';

class BookmarksScreen
    extends StatefulWidget {

  const BookmarksScreen({
    super.key,
  });

  @override
  State<BookmarksScreen>
  createState() =>
      _BookmarksScreenState();
}

class _BookmarksScreenState
    extends State<BookmarksScreen> {

  List<BookmarkModel>
  bookmarks = [];

  @override
  void initState() {
    super.initState();

    loadBookmarks();
  }

  Future<void>
  loadBookmarks() async {

    final data =
    await PreferencesService
        .getBookmarks();

    setState(() {

      bookmarks = data;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFF0B1819),

      appBar: AppBar(

        title: const Text(
          'العلامات المرجعية',
        ),
      ),

      body: bookmarks.isEmpty

          ? const Center(

        child: Text(

          'لا توجد اي علامات مرجعية',

          style: TextStyle(
            color: Colors.white,
          ),
        ),
      )

          : ListView.builder(

        padding:
        const EdgeInsets
            .all(20),

        itemCount:
        bookmarks.length,

        itemBuilder:
            (context, index) {

          final bookmark =
          bookmarks[index];

          return Container(

            margin:
            const EdgeInsets
                .only(
              bottom: 16,
            ),

            decoration:
            BoxDecoration(

              color:
              AppColors
                  .forestGreen,

              borderRadius:
              BorderRadius
                  .circular(
                18,
              ),
            ),

            child: ListTile(

              title: Text(

                bookmark.name,

                textDirection:
                TextDirection.rtl,

                style: const TextStyle(

                  color: Colors.white,

                  fontWeight:
                  FontWeight.bold,

                  fontSize: 18,
                ),
              ),

              subtitle: Text(

                'الصفحة ${bookmark.page + 1}',

                textDirection:
                TextDirection.rtl,

                style: const TextStyle(

                  color: Colors.white70,
                ),
              ),

              leading: const Icon(

                Icons.bookmark,

                color:
                AppColors.teal,
              ),

              trailing:
              IconButton(

                onPressed:
                    () async {

                  await PreferencesService
                      .deleteBookmark(
                    index,
                  );

                  loadBookmarks();
                },

                icon:
                const Icon(

                  Icons.delete,

                  color:
                  Colors.red,
                ),
              ),

                onTap: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) => ReaderScreen(

                        surahName: bookmark.name,
                        initialPage: bookmark.page+1,
                      ),
                    ),
                  );
                },
            ),
          );
        },
      ),
    );
  }
}