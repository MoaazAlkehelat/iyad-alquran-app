import 'package:flutter/material.dart';
import 'package:iyad_alquran/core/constants/app_colors.dart';

import '../../../data/models/azkar_category_model.dart';

class ZikrDetailsScreen extends StatefulWidget {
  final AzkarCategoryModel category;

  const ZikrDetailsScreen({
    super.key,
    required this.category,
  });

  @override
  State<ZikrDetailsScreen> createState() => _ZikrDetailsScreenState();
}

class _ZikrDetailsScreenState extends State<ZikrDetailsScreen> {
  /// How many times each zikr has been recited so far. Starts at zero.
  late List<int> counts;

  @override
  void initState() {
    super.initState();
    counts = List<int>.filled(widget.category.azkar.length, 0);
  }

  void _tasbih(int index) {
    final target = widget.category.azkar[index].count;
    if (counts[index] < target) {
      setState(() => counts[index]++);
    }
  }

  void _reset(int index) => setState(() => counts[index] = 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.category,
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.category.azkar.length,
        itemBuilder: (context, index) {
          final zikr = widget.category.azkar[index];
          final done = counts[index];
          final target = zikr.count;
          final progress = target == 0 ? 0.0 : (done / target).clamp(0.0, 1.0);
          final finished = done >= target;

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.forestGreen,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: finished ? null : () => _tasbih(index),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      zikr.text,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        height: 2,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 25),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        color: AppColors.teal,
                        backgroundColor: Colors.white12,
                        value: progress,
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: AppColors.teal.withValues(alpha: 0.12),
                          ),
                          child: Text(
                            '$done / $target',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            if (done > 0)
                              IconButton(
                                onPressed: () => _reset(index),
                                icon: const Icon(Icons.refresh_rounded,
                                    color: Colors.white54),
                                tooltip: 'إعادة',
                              ),
                            ElevatedButton(
                              onPressed:
                                  finished ? null : () => _tasbih(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.teal.withValues(alpha: 0.16),
                                disabledBackgroundColor:
                                    Colors.white.withValues(alpha: 0.06),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Text(
                                finished ? 'تم ✓' : 'تسبيح',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
