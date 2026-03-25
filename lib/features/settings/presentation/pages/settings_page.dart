import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/constants/app_icons.dart';
import 'package:du_an/core/constants/app_images.dart';
import 'package:du_an/features/settings/presentation/pages/keyword_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _isNotificationEnabled = true;
  String _selectedCurrency = 'VND';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cai dat'),
        actions: [
          // Example: Using SVG icon in AppBar
          IconButton(
            icon: SvgPicture.asset(
              AppIcons.settings,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Profile section with logo example
          Center(
            child: Column(
              children: [
                // Example: Using SVG image as avatar/logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: ClipOval(
                    child: SvgPicture.asset(
                      AppImages.logo,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Expense Manager',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Phien ban 1.0.0',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // General settings
          _buildSectionHeader('Chung'),
          _buildSwitchTile(
            icon: Icons.dark_mode,
            title: 'Che do toi',
            subtitle: 'Chuyen doi giao dien sang/toi',
            value: _isDarkMode,
            onChanged: (value) => setState(() => _isDarkMode = value),
          ),
          _buildSwitchTile(
            icon: Icons.notifications,
            title: 'Thong bao',
            subtitle: 'Nhan thong bao nhac nho',
            value: _isNotificationEnabled,
            onChanged: (value) => setState(() => _isNotificationEnabled = value),
          ),
          _buildActionTile(
            icon: Icons.keyboard,
            title: 'Từ khóa thông minh',
            subtitle: 'Quản lý từ khóa, danh mục, ngày lương',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KeywordSettingsPage())),
          ),
          _buildDropdownTile(
            icon: Icons.attach_money,
            title: 'Don vi tien te',
            value: _selectedCurrency,
            items: ['VND', 'USD', 'EUR'],
            onChanged: (value) => setState(() => _selectedCurrency = value ?? 'VND'),
          ),

          const SizedBox(height: 8),
          _buildSectionHeader('Du lieu'),
          _buildActionTile(
            icon: Icons.backup,
            title: 'Sao luu du lieu',
            subtitle: 'Sao luu du lieu len may chu',
            onTap: () => _showSnackbar('Tinh nang dang phat trien'),
          ),
          _buildActionTile(
            icon: Icons.restore,
            title: 'Khoi phuc du lieu',
            subtitle: 'Khoi phuc tu ban sao luu',
            onTap: () => _showSnackbar('Tinh nang dang phat trien'),
          ),
          _buildActionTile(
            icon: Icons.delete_outline,
            title: 'Xoa tat ca du lieu',
            subtitle: 'Xoa toan bo giao dich',
            onTap: () => _showDeleteConfirmation(),
            isDestructive: true,
          ),

          const SizedBox(height: 8),
          _buildSectionHeader('Thong tin'),
          _buildActionTile(
            icon: Icons.info_outline,
            title: 'Gioi thieu',
            subtitle: 'Thong tin ung dung',
            onTap: () => _showAboutDialog(),
          ),
          _buildActionTile(
            icon: Icons.star_outline,
            title: 'Danh gia ung dung',
            subtitle: 'Danh gia tren App Store',
            onTap: () => _showSnackbar('Tinh nang dang phat trien'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.primary),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? AppColors.error : null),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoa du lieu'),
        content: const Text('Ban co chac chan muon xoa tat ca du lieu? Hanh dong nay khong the hoan tac.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackbar('Da xoa tat ca du lieu');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            SvgPicture.asset(AppImages.logo, width: 32, height: 32),
            const SizedBox(width: 12),
            const Text('Expense Manager'),
          ],
        ),
        content: const Text(
          'Ung dung quan ly chi tieu ca nhan.\n\n'
          'Phien ban: 1.0.0\n'
          'Phat trien boi Flutter & Clean Architecture.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dong'),
          ),
        ],
      ),
    );
  }
}
