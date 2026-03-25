import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/date_utils.dart';

class CategoryBar extends StatelessWidget {
  final String category;
  final double amount;
  final double percentage;

  const CategoryBar({super.key, required this.category, required this.amount, required this.percentage});

  static const _categoryConfig = <String, Map<String, dynamic>>{
    'An uong': {'icon': Icons.restaurant, 'color': Color(0xFFFF7043)},
    'Di lai': {'icon': Icons.directions_car, 'color': Color(0xFF42A5F5)},
    'Mua sam': {'icon': Icons.shopping_bag, 'color': Color(0xFFAB47BC)},
    'Giai tri': {'icon': Icons.movie, 'color': Color(0xFFFFCA28)},
    'Suc khoe': {'icon': Icons.local_hospital, 'color': Color(0xFFEF5350)},
    'Hoc tap': {'icon': Icons.school, 'color': Color(0xFF26A69A)},
    'Hoa don': {'icon': Icons.receipt, 'color': Color(0xFF78909C)},
    'Khac': {'icon': Icons.more_horiz, 'color': Color(0xFF8D6E63)},
  };

  @override
  Widget build(BuildContext context) {
    final config = _categoryConfig[category] ?? _categoryConfig['Khac']!;
    final color = config['color'] as Color;
    final icon = config['icon'] as IconData;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(category, style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text(AppDateUtils.formatCurrency(amount), style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('${percentage.toStringAsFixed(1)}%', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
