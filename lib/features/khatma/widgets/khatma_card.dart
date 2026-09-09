import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/quran_constants.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/arabic.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/khatma_model.dart';
import '../../../data/services/khatma_service.dart';
import 'khatma_ring.dart';

String _arDate(DateTime d) =>
    '${toArabicDigits(d.day)}/${toArabicDigits(d.month)}/${toArabicDigits(d.year)}';

/// The Khatma block on the dashboard. Self-contained: loads its own state and
/// can be refreshed by the parent via a [GlobalKey] after returning from the
/// reader.
class KhatmaCard extends StatefulWidget {
  const KhatmaCard({super.key});

  @override
  KhatmaCardState createState() => KhatmaCardState();
}

class KhatmaCardState extends State<KhatmaCard> {
  KhatmaModel? _khatma;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    final k = await KhatmaService.getKhatma();
    if (!mounted) return;
    setState(() {
      _khatma = k;
      _loading = false;
    });
  }

  Future<void> _createOrEdit({KhatmaModel? existing}) async {
    final result = await showDialog<_KhatmaForm>(
      context: context,
      builder: (_) => _KhatmaDialog(existing: existing),
    );
    if (result == null) return;

    final base = existing ??
        KhatmaModel(
          dailyPages: result.dailyPages,
          startPage: 1,
          currentPage: 1,
          startDate: DateTime.now(),
          completed: false,
        );
    await KhatmaService.saveKhatma(
      base.copyWith(dailyPages: result.dailyPages, targetDate: result.targetDate),
    );
    await reload();
  }

  Future<void> _recordProgress(KhatmaModel k) async {
    final page = await showDialog<int>(
      context: context,
      builder: (_) => _RecordProgressDialog(current: k.currentPage),
    );
    if (page == null) return;
    final newPage = page.clamp(1, kQuranPageCount);
    await KhatmaService.saveKhatma(
      k.copyWith(
        currentPage: newPage,
        completed: newPage >= kQuranPageCount,
        lastReadDate: DateTime.now(),
      ),
    );
    await reload();
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        backgroundColor: AppColors.forestGreen,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardR),
        title: Text('إعادة الختمة',
            textDirection: TextDirection.rtl,
            style: AppTextStyles.heading(color: Colors.white, fontSize: 18)),
        content: Text('سيتم حذف تقدّمك الحالي. هل أنت متأكد؟',
            textDirection: TextDirection.rtl,
            style: AppTextStyles.bodyAr(color: Colors.white70, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx, false),
            child: Text('إلغاء', style: AppTextStyles.bodyAr(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(dctx, true),
            child: Text('حذف', style: AppTextStyles.bodyAr(weight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await KhatmaService.clearKhatma();
      await reload();
    }
  }

  void _openDetails(KhatmaModel k) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.forestGreen,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => _KhatmaDetailsSheet(
        khatma: k,
        onRecord: () {
          Navigator.pop(context);
          _recordProgress(k);
        },
        onEdit: () {
          Navigator.pop(context);
          _createOrEdit(existing: k);
        },
        onReset: () {
          Navigator.pop(context);
          _confirmReset();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return AppCard(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2.5),
          ),
        ),
      );
    }
    return _khatma == null ? _buildEmpty() : _buildActive(_khatma!);
  }

  Widget _buildEmpty() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.menu_book_rounded,
                  size: 26, color: AppColors.teal),
            ),
            const SizedBox(height: AppSpace.md),
            Text('ابدأ ختمتك القرآنية',
                style: AppTextStyles.title.copyWith(fontSize: 20)),
            const SizedBox(height: AppSpace.sm),
            Text(
              'حدّد وردك اليومي وابدأ رحلتك مع كتاب الله',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted.copyWith(fontSize: 13),
            ),
            const SizedBox(height: AppSpace.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.fieldR),
                ),
                onPressed: () => _createOrEdit(),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text('ابدأ الختمة',
                    style: AppTextStyles.bodyAr(weight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActive(KhatmaModel k) {
    final progress = KhatmaService.getProgress(k);
    final todayStart = KhatmaService.getTodayStartPage(k);
    final todayEnd = KhatmaService.getTodayEndPage(k);
    final remaining = KhatmaService.getRemainingPages(k);
    final remainingDays = KhatmaService.getRemainingDays(k);
    final pace = KhatmaService.getPace(k);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AppCard(
        onTap: () => _openDetails(k),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_stories_rounded,
                    color: AppColors.teal, size: 18),
                const SizedBox(width: AppSpace.sm),
                Text('الختمة الحالية',
                    style: AppTextStyles.title.copyWith(fontSize: 17)),
                const Spacer(),
                _PaceChip(pace: pace),
              ],
            ),
            const SizedBox(height: AppSpace.lg),
            Row(
              children: [
                KhatmaRing(progress: progress, size: 112),
                const SizedBox(width: AppSpace.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatLine(
                        icon: Icons.today_rounded,
                        label: 'ورد اليوم',
                        value:
                            '${toArabicDigits(todayStart)} – ${toArabicDigits(todayEnd)}',
                      ),
                      const SizedBox(height: AppSpace.sm),
                      _StatLine(
                        icon: Icons.bookmark_rounded,
                        label: 'الصفحة الحالية',
                        value: toArabicDigits(k.currentPage),
                      ),
                      const SizedBox(height: AppSpace.sm),
                      _StatLine(
                        icon: Icons.flag_rounded,
                        label: 'المتبقّي',
                        value:
                            '${toArabicDigits(remaining)} ص · ${toArabicDigits(remainingDays)} يوم',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                minHeight: 7,
                value: progress,
                color: AppColors.teal,
                backgroundColor: AppColors.divider,
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('اضغط للتفاصيل',
                    style: AppTextStyles.caption.copyWith(fontSize: 11)),
                Text('٪${toArabicDigits((progress * 100).round())}',
                    style: AppTextStyles.numeric(
                        color: AppColors.blueGreen, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatLine({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.blueGreen),
        const SizedBox(width: AppSpace.sm),
        Text('$label: ',
            style: AppTextStyles.caption.copyWith(fontSize: 12)),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyAr(
                color: Colors.white, fontSize: 13, weight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _PaceChip extends StatelessWidget {
  final KhatmaPace pace;
  const _PaceChip({required this.pace});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;
    late final IconData icon;
    switch (pace) {
      case KhatmaPace.ahead:
        label = 'متقدّم';
        color = AppColors.spearmint;
        icon = Icons.trending_up_rounded;
      case KhatmaPace.onTrack:
        label = 'على المسار';
        color = AppColors.teal;
        icon = Icons.check_circle_rounded;
      case KhatmaPace.behind:
        label = 'متأخّر';
        color = const Color(0xFFE0A85B);
        icon = Icons.error_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: AppTextStyles.bodyAr(
                  color: color, fontSize: 11, weight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _KhatmaDetailsSheet extends StatelessWidget {
  final KhatmaModel khatma;
  final VoidCallback onRecord;
  final VoidCallback onEdit;
  final VoidCallback onReset;

  const _KhatmaDetailsSheet({
    required this.khatma,
    required this.onRecord,
    required this.onEdit,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final eta = KhatmaService.getEstimatedFinishDate(khatma);
    final perTarget = KhatmaService.getPagesPerDayForTarget(khatma);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpace.xl, AppSpace.lg, AppSpace.xl, AppSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              Text('تفاصيل الختمة',
                  style: AppTextStyles.title.copyWith(fontSize: 19)),
              const SizedBox(height: AppSpace.md),
              _row('الورد اليومي', '${toArabicDigits(khatma.dailyPages)} صفحة'),
              _row('تاريخ البدء', _arDate(khatma.startDate)),
              _row('الانتهاء المتوقّع', _arDate(eta)),
              if (khatma.targetDate != null)
                _row('الهدف', _arDate(khatma.targetDate!)),
              if (perTarget != null)
                _row('للوصول للهدف', '${toArabicDigits(perTarget)} صفحة/يوم'),
              const SizedBox(height: AppSpace.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.fieldR),
                  ),
                  onPressed: onRecord,
                  icon: const Icon(Icons.checklist_rounded, size: 18),
                  label: Text('سجّل قراءتك (داخل التطبيق أو من المصحف)',
                      style: AppTextStyles.bodyAr(weight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: AppSpace.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.teal,
                        side: const BorderSide(color: AppColors.teal),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape:
                            RoundedRectangleBorder(borderRadius: AppRadius.fieldR),
                      ),
                      onPressed: onEdit,
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: Text('تعديل الورد',
                          style: AppTextStyles.bodyAr(weight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade300,
                        side: BorderSide(color: Colors.red.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape:
                            RoundedRectangleBorder(borderRadius: AppRadius.fieldR),
                      ),
                      onPressed: onReset,
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                      label: Text('إعادة',
                          style: AppTextStyles.bodyAr(weight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: AppTextStyles.bodyMuted.copyWith(fontSize: 13)),
            Text(value,
                style: AppTextStyles.bodyAr(
                    color: Colors.white, fontSize: 14, weight: FontWeight.bold)),
          ],
        ),
      );
}

/// Result of the create/edit dialog.
class _KhatmaForm {
  final int dailyPages;
  final DateTime? targetDate;
  _KhatmaForm(this.dailyPages, this.targetDate);
}

class _KhatmaDialog extends StatefulWidget {
  final KhatmaModel? existing;
  const _KhatmaDialog({this.existing});

  @override
  State<_KhatmaDialog> createState() => _KhatmaDialogState();
}

class _KhatmaDialogState extends State<_KhatmaDialog> {
  late final TextEditingController _controller;
  DateTime? _targetDate;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.existing != null ? '${widget.existing!.dailyPages}' : '',
    );
    _targetDate = widget.existing?.targetDate;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final pages = int.tryParse(_controller.text.trim());
    if (pages == null || pages <= 0) {
      setState(() => _error = 'أدخل عدداً صحيحاً أكبر من صفر');
      return;
    }
    if (pages > 604) {
      setState(() => _error = 'العدد كبير جداً');
      return;
    }
    Navigator.pop(context, _KhatmaForm(pages, _targetDate));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.forestGreen,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardR),
      title: Text(
        widget.existing == null ? 'عدد الصفحات يومياً' : 'تعديل الورد اليومي',
        textDirection: TextDirection.rtl,
        style: AppTextStyles.heading(color: Colors.white, fontSize: 18),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.rtl,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'مثال: ٢٠',
              hintTextDirection: TextDirection.rtl,
              hintStyle: const TextStyle(color: Colors.white54),
              errorText: _error,
              filled: true,
              fillColor: AppColors.background,
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.fieldR,
                borderSide: const BorderSide(color: AppColors.teal),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.fieldR,
                borderSide: const BorderSide(color: AppColors.blueGreen, width: 2),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Row(
            children: [
              const Icon(Icons.event_rounded, size: 18, color: AppColors.blueGreen),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: Text(
                  _targetDate == null
                      ? 'تاريخ هدف (اختياري)'
                      : 'الهدف: ${_arDate(_targetDate!)}',
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.bodyAr(color: Colors.white70, fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _targetDate ?? now.add(const Duration(days: 30)),
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 366 * 3)),
                  );
                  if (picked != null) setState(() => _targetDate = picked);
                },
                child: Text(_targetDate == null ? 'اختر' : 'تغيير',
                    style: AppTextStyles.bodyAr(color: AppColors.teal)),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء', style: AppTextStyles.bodyAr(color: Colors.white70)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal, foregroundColor: Colors.black),
          onPressed: _submit,
          child: Text('حفظ', style: AppTextStyles.bodyAr(weight: FontWeight.bold)),
        ),
      ],
    );
  }
}

/// Lets the reader set the page they've reached — whether inside the app or by
/// reading a physical mushaf and coming back.
class _RecordProgressDialog extends StatefulWidget {
  final int current;
  const _RecordProgressDialog({required this.current});

  @override
  State<_RecordProgressDialog> createState() => _RecordProgressDialogState();
}

class _RecordProgressDialogState extends State<_RecordProgressDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.current}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add(int pages) {
    final v = (int.tryParse(_controller.text.trim()) ?? widget.current) + pages;
    _controller.text = '${v.clamp(1, kQuranPageCount)}';
  }

  void _submit() {
    final page = int.tryParse(_controller.text.trim());
    if (page == null || page < 1 || page > kQuranPageCount) {
      setState(() => _error = 'أدخل رقم صفحة بين ١ و ٦٠٤');
      return;
    }
    Navigator.pop(context, page);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.forestGreen,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardR),
      title: Text('سجّل تقدّمك',
          textDirection: TextDirection.rtl,
          style: AppTextStyles.heading(color: Colors.white, fontSize: 18)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('وصلت إلى صفحة رقم:',
              textDirection: TextDirection.rtl,
              style: AppTextStyles.bodyAr(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: AppSpace.sm),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.rtl,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              errorText: _error,
              filled: true,
              fillColor: AppColors.background,
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.fieldR,
                borderSide: const BorderSide(color: AppColors.teal),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.fieldR,
                borderSide: const BorderSide(color: AppColors.blueGreen, width: 2),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Wrap(
            spacing: AppSpace.sm,
            children: [
              for (final n in const [5, 10, 20])
                ActionChip(
                  label: Text('+${toArabicDigits(n)}',
                      style: AppTextStyles.bodyAr(color: AppColors.teal, fontSize: 12)),
                  backgroundColor: AppColors.teal.withValues(alpha: 0.12),
                  side: BorderSide(color: AppColors.teal.withValues(alpha: 0.4)),
                  onPressed: () => _add(n),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء', style: AppTextStyles.bodyAr(color: Colors.white70)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal, foregroundColor: Colors.black),
          onPressed: _submit,
          child: Text('حفظ', style: AppTextStyles.bodyAr(weight: FontWeight.bold)),
        ),
      ],
    );
  }
}
