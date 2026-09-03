import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/arabic.dart';
import '../../../core/widgets/app_card.dart';
import 'package:iyad_alquran/data/models/bookmark_model.dart';
import 'package:iyad_alquran/data/services/preferences_service.dart';
import '../../quran/screens/reader_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<BookmarkModel> bookmarks = [];

  @override
  void initState() {
    super.initState();
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    final data = await PreferencesService.getBookmarks();
    if (mounted) setState(() => bookmarks = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text('العلامات المرجعية',
            style: AppTextStyles.heading(color: Colors.white, fontSize: 22)),
      ),
      body: bookmarks.isEmpty
          ? _empty()
          : ListView.separated(
              padding: AppSpace.screen,
              itemCount: bookmarks.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpace.md),
              itemBuilder: (context, index) {
                final b = bookmarks[index];
                return AppCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.lg, vertical: AppSpace.md),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReaderScreen(
                        surahName: b.name,
                        initialPage: b.page,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(AppRadius.field),
                        ),
                        child: const Icon(Icons.bookmark_rounded,
                            color: AppColors.teal, size: 20),
                      ),
                      const SizedBox(width: AppSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.name,
                              textDirection: TextDirection.rtl,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyAr(
                                  color: Colors.white,
                                  fontSize: 15,
                                  weight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text('صفحة ${toArabicDigits(b.page)}',
                                textDirection: TextDirection.rtl,
                                style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () async {
                          await PreferencesService.deleteBookmark(index);
                          loadBookmarks();
                        },
                        icon: Icon(Icons.delete_outline_rounded,
                            color: Colors.red.shade300),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bookmark_border_rounded,
              size: 56, color: AppColors.teal.withValues(alpha: 0.6)),
          const SizedBox(height: AppSpace.md),
          Text('لا توجد علامات مرجعية بعد',
              style: AppTextStyles.bodyMuted.copyWith(fontSize: 15)),
          const SizedBox(height: AppSpace.xs),
          Text('احفظ صفحتك من داخل المصحف',
              style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
