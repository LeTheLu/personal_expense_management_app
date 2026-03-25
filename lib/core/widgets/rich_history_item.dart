import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/date_utils.dart';

class RichHistoryItem extends StatelessWidget {
  final String action;
  final String description;
  final double? oldAmount;
  final double? newAmount;
  final DateTime date;
  final bool isFirst;
  final bool isLast;

  // Action config maps
  static const _actionColors = <String, Color>{
    'created': AppColors.income,
    'updated': AppColors.secondary,
    'addedAmount': AppColors.primary,
    'deducted': AppColors.warning,
    'refunded': AppColors.info,
    'spent': AppColors.warning,
    'deleted': AppColors.expense,
  };

  static const _actionIcons = <String, IconData>{
    'created': Icons.add_circle_outline,
    'updated': Icons.edit_outlined,
    'addedAmount': Icons.add_chart,
    'deducted': Icons.remove_circle_outline,
    'refunded': Icons.replay,
    'spent': Icons.shopping_cart_outlined,
    'deleted': Icons.delete_outline,
  };

  static const _actionLabels = <String, String>{
    'created': 'Tạo mới',
    'updated': 'Chỉnh sửa',
    'addedAmount': 'Cộng dồn',
    'deducted': 'Trừ tiền',
    'refunded': 'Hoàn trả',
    'spent': 'Chi tiêu',
    'deleted': 'Xóa',
  };

  const RichHistoryItem({
    super.key,
    required this.action,
    required this.description,
    this.oldAmount,
    this.newAmount,
    required this.date,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _actionColors[action] ?? AppColors.textSecondary;
    final icon = _actionIcons[action] ?? Icons.info_outline;
    final label = _actionLabels[action] ?? action;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (!isFirst) Container(width: 2, height: 8, color: Colors.grey.shade300),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Icon(icon, size: 14, color: color),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                      ),
                      Text(AppDateUtils.formatDateTime(date), style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(description, style: const TextStyle(fontSize: 13)),
                  if (oldAmount != null && newAmount != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          AppDateUtils.formatCurrency(oldAmount!),
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500, decoration: TextDecoration.lineThrough),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 8),
                        Text(
                          AppDateUtils.formatCurrency(newAmount!),
                          style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
