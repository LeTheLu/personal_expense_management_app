import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';

class SmartInputSuggestion {
  final String label;
  final String insertText;
  final IconData? icon;
  final Color color;

  const SmartInputSuggestion({
    required this.label,
    required this.insertText,
    this.icon,
    this.color = AppColors.primary,
  });
}

class SmartInputSuggestions extends StatelessWidget {
  final List<SmartInputSuggestion> suggestions;
  final ValueChanged<SmartInputSuggestion> onSelected;

  const SmartInputSuggestions({super.key, required this.suggestions, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: suggestions.map((s) => GestureDetector(
          onTap: () => onSelected(s),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: s.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: s.color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (s.icon != null) ...[
                  Icon(s.icon, size: 14, color: s.color),
                  const SizedBox(width: 4),
                ],
                Text(s.label, style: TextStyle(fontSize: 12, color: s.color, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }
}
