import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/state/app_settings.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/arabic.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/services/app_state_service.dart';
import '../../../data/services/khatma_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final name = await AppStateService.getUsername();
    if (mounted) setState(() => _username = name ?? '');
  }

  Future<void> _changeName() async {
    final controller = TextEditingController(text: _username);
    await showDialog<void>(
      context: context,
      builder: (dctx) => AlertDialog(
        backgroundColor: AppColors.forestGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('تغيير الاسم',
            textDirection: TextDirection.rtl,
            style: AppTextStyles.heading(color: Colors.white, fontSize: 18)),
        content: TextField(
          controller: controller,
          textDirection: TextDirection.rtl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal, foregroundColor: Colors.black),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;
              final nav = Navigator.of(dctx);
              await AppStateService.saveUsername(newName);
              if (!mounted) return;
              setState(() => _username = newName);
              nav.pop();
            },
            child: Text('حفظ', style: AppTextStyles.bodyAr(weight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text('الإعدادات',
            style: AppTextStyles.heading(color: Colors.white, fontSize: 22)),
      ),
      body: ListView(
        padding: AppSpace.screen,
        children: [
          _profileCard(),
          const SizedBox(height: AppSpace.xl),
          const SectionHeader('الحساب'),
          _group([
            _tile(icon: Icons.person_outline_rounded, title: 'تغيير الاسم', onTap: _changeName),
          ]),
          const SizedBox(height: AppSpace.xl),
          const SectionHeader('القراءة'),
          _group([
            _tile(
              icon: Icons.dark_mode_outlined,
              title: 'الوضع الليلي',
              trailing: Switch(
                value: settings.isDarkMode,
                activeThumbColor: AppColors.teal,
                onChanged: settings.setDarkMode,
              ),
            ),
            _divider(),
            _fontSizeTile(settings),
          ]),
          const SizedBox(height: AppSpace.xl),
          const SectionHeader('الختمة'),
          _group([
            _tile(
              icon: Icons.restart_alt_rounded,
              title: 'إعادة الختمة',
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                await KhatmaService.clearKhatma();
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('تم حذف الختمة')),
                );
              },
            ),
          ]),
          const SizedBox(height: AppSpace.xl),
          const SectionHeader('عن'),
          _group([
            _tile(icon: Icons.info_outline_rounded, title: 'عن التطبيق', onTap: _showAbout),
            _divider(),
            _tile(
              icon: Icons.share_outlined,
              title: 'مشاركة التطبيق',
              onTap: () => Share.share(
                'حمّل تطبيق إياد القرآن 🌿\n\n'
                'رفيقك اليومي لقراءة القرآن والأذكار والدعاء.\n\n'
                'https://your-app-link.com',
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _group(List<Widget> children) {
    return Container(
      decoration: AppSurface.tile(),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.only(right: 52),
        child: Container(height: 1, color: AppColors.teal.withValues(alpha: 0.12)),
      );

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: AppSurface.card(),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.teal,
            child: Icon(Icons.person, color: Colors.black, size: 30),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_username.isEmpty ? 'مستخدم' : _username,
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.title.copyWith(fontSize: 18)),
                const SizedBox(height: 2),
                Text('قارئ القرآن', style: AppTextStyles.caption),
              ],
            ),
          ),
          IconButton(
            onPressed: _changeName,
            icon: const Icon(Icons.edit_outlined,
                color: AppColors.blueGreen, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _fontSizeTile(AppSettings settings) {
    final pct = (settings.readingFontScale * 100).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.md, AppSpace.lg, AppSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.format_size, color: AppColors.teal),
              const SizedBox(width: 12),
              Expanded(
                child: Text('حجم خط القراءة',
                    textDirection: TextDirection.rtl,
                    style:
                        AppTextStyles.bodyAr(color: Colors.white, fontSize: 15)),
              ),
              Text('٪${toArabicDigits(pct)}',
                  style: AppTextStyles.numeric(
                      color: AppColors.blueGreen, fontSize: 13)),
            ],
          ),
          Slider(
            value: settings.readingFontScale,
            min: AppSettings.minFontScale,
            max: AppSettings.maxFontScale,
            divisions: 10,
            activeColor: AppColors.teal,
            onChanged: settings.setReadingFontScale,
          ),
          Text(
            'مثال: ﴿ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ﴾',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: AppTextStyles.quranBody.copyWith(
              color: Colors.white,
              fontSize: 20 * settings.readingFontScale,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.teal, size: 22),
      trailing: trailing ??
          (onTap == null
              ? null
              : const Icon(Icons.chevron_left_rounded,
                  color: AppColors.blueGreen, size: 20)),
      title: Text(title,
          textDirection: TextDirection.rtl,
          style: AppTextStyles.bodyAr(color: Colors.white, fontSize: 15)),
    );
  }

  void _showAbout() {
    // Force a light theme for this dialog so "عن التطبيق" stays white even in
    // dark mode.
    showDialog<void>(
      context: context,
      builder: (_) => Theme(
        data: ThemeData.light(),
        child: AboutDialog(
          applicationName: 'إياد القرآن',
          applicationVersion: '1.0.0',
          applicationIcon: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.teal,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.menu_book_rounded,
                color: Colors.black, size: 34),
          ),
          children: [
            const SizedBox(height: 14),
            Text(
              'إياد القرآن 🌿\n\n'
              'تطبيق قرآني صُمم ليكون صدقة جارية عن روح إياد النواجحة، '
              'ورفيقًا يوميًا يساعد المسلم على قراءة القرآن الكريم والأذكار '
              'والدعاء بسهولة وطمأنينة.',
              textDirection: TextDirection.rtl,
              style:
                  AppTextStyles.bodyAr(color: Colors.black87).copyWith(height: 1.8),
            ),
          ],
        ),
      ),
    );
  }
}
