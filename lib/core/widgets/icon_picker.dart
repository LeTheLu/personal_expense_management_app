import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/widgets/full_icon_browser.dart';

class IconPicker extends StatelessWidget {
  final List<IconData> suggestedIcons;
  final IconData selectedIcon;
  final Set<int> usedIcons;
  final ValueChanged<IconData> onSelected;

  const IconPicker({
    super.key,
    required this.suggestedIcons,
    required this.selectedIcon,
    this.usedIcons = const {},
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Filter out used icons (except currently selected)
    final available = suggestedIcons.where((icon) {
      return icon.codePoint == selectedIcon.codePoint || !usedIcons.contains(icon.codePoint);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chọn biểu tượng:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...available.map((icon) {
              final isSelected = icon.codePoint == selectedIcon.codePoint;
              return GestureDetector(
                onTap: () => onSelected(icon),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 1.5),
                  ),
                  child: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey.shade600, size: 22),
                ),
              );
            }),
            // [...] button to open full browser
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push<IconData>(
                  context,
                  MaterialPageRoute(builder: (_) => FullIconBrowser(usedIcons: usedIcons)),
                );
                if (result != null) onSelected(result);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Icon(Icons.more_horiz, color: Colors.grey.shade600, size: 22),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
