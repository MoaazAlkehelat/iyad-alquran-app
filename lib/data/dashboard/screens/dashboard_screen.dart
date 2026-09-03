import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/arabic.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/services/app_state_service.dart';
import '../../../features/azkar/screens/azkar_screen.dart';
import '../../../features/dua/screens/dua_screen.dart';
import '../../../features/khatma/widgets/khatma_card.dart';
import '../../../features/quran/data/quran_repository.dart';
import '../../../features/quran/screens/reader_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _khatmaKey = GlobalKey<KhatmaCardState>();
  final _nameController = TextEditingController();

  String? _username;
  int _lastPage = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final name = await AppStateService.getUsername();
    final page = await AppStateService.getLastPage();
    if (!mounted) return;
    setState(() {
      _username = name;
      _lastPage = page;
    });
    if (name == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _askName());
    }
  }

  Future<void> _askName() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dctx) => AlertDialog(
        backgroundColor: AppColors.forestGreen,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardR),
        title: Text('ما اسمك؟',
            textDirection: TextDirection.rtl,
            style: AppTextStyles.heading(color: Colors.white, fontSize: 18)),
        content: TextField(
          controller: _nameController,
          textDirection: TextDirection.rtl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
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
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal, foregroundColor: Colors.black),
            onPressed: () async {
              final name = _nameController.text.trim();
              if (name.isEmpty) return;
              final nav = Navigator.of(dctx);
              await AppStateService.saveUsername(name);
              if (!mounted) return;
              setState(() => _username = name);
              nav.pop();
            },
            child: Text('حفظ', style: AppTextStyles.bodyAr(weight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _openReader(int page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReaderScreen(initialPage: page)),
    );
    final latest = await AppStateService.getLastPage();
    if (mounted) setState(() => _lastPage = latest);
    _khatmaKey.currentState?.reload();
  }

  String get _lastSurahName {
    try {
      final block =
          QuranRepository.instance.pageContent(_lastPage).blocks.first;
      return QuranRepository.instance.surahNameAr(block.surahNumber);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.forestGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: AppSpace.screen,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpace.sm),
                  Text('إياد القرآن • رفيقك إلى كتاب الله',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.blueGreen, fontSize: 13)),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    (_username == null || _username!.isEmpty)
                        ? 'السلام عليكم'
                        : 'أهلاً، $_username',
                    style: AppTextStyles.display,
                  ),
                  const SizedBox(height: AppSpace.xl),
                  const SectionHeader('متابعة القراءة'),
                  _lastReadCard(),
                  const SizedBox(height: AppSpace.xl),
                  const SectionHeader('الختمة'),
                  KhatmaCard(key: _khatmaKey),
                  const SizedBox(height: AppSpace.xl),
                  const SectionHeader('أذكار وأدعية'),
                  _navCard(
                    icon: Icons.favorite_rounded,
                    title: 'دعاء للميت',
                    subtitle: 'رحمةٌ ودعاءٌ لمن نحب',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const DuaScreen())),
                  ),
                  const SizedBox(height: AppSpace.md),
                  _navCard(
                    icon: Icons.menu_book_rounded,
                    title: 'الأذكار',
                    subtitle: 'ألا بذكر الله تطمئن القلوب',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AzkarScreen())),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _lastReadCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBadge(Icons.auto_stories_rounded),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('آخر قراءة', style: AppTextStyles.caption),
                    const SizedBox(height: 2),
                    Text('الصفحة ${toArabicDigits(_lastPage)}',
                        style: AppTextStyles.title.copyWith(fontSize: 22)),
                    if (_lastSurahName.isNotEmpty)
                      Text('سورة $_lastSurahName',
                          style: AppTextStyles.bodyMuted.copyWith(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.fieldR),
              ),
              onPressed: () => _openReader(_lastPage),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text('أكمل القراءة',
                  style: AppTextStyles.bodyAr(weight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          _iconBadge(icon),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title.copyWith(fontSize: 18)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTextStyles.bodyMuted.copyWith(fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_left_rounded,
              color: AppColors.teal, size: 22),
        ],
      ),
    );
  }

  Widget _iconBadge(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      child: Icon(icon, color: AppColors.teal, size: 22),
    );
  }
}
