import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/date_utils.dart';
import 'package:du_an/features/home/domain/entities/fixed_expense.dart';

class FixedExpenseSection extends StatelessWidget {
  final List<FixedExpense> fixedExpenses;
  final ValueChanged<String>? onTogglePaid;
  final VoidCallback? onAdd;
  final ValueChanged<String>? onTap;

  const FixedExpenseSection({super.key, required this.fixedExpenses, this.onTogglePaid, this.onAdd, this.onTap});

  @override
  Widget build(BuildContext context) {
    final unpaid = fixedExpenses.where((f) => !f.isPaid).toList();
    final paid = fixedExpenses.where((f) => f.isPaid).toList();
    final totalPaid = paid.fold(0.0, (sum, f) => sum + f.amount);
    final totalAll = fixedExpenses.fold(0.0, (sum, f) => sum + f.amount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Chi phí cố định', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  if (fixedExpenses.isNotEmpty)
                    Text('${AppDateUtils.formatCurrency(totalPaid)} / ${AppDateUtils.formatCurrency(totalAll)}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (fixedExpenses.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.receipt_long, color: Colors.grey.shade400, size: 32),
                  const SizedBox(height: 8),
                  Text('Chưa có chi phí cố định', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                ],
              ),
            )
          else ...[
            ...unpaid.map(_item),
            if (paid.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('Đã thanh toán', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500)),
              ),
              ...paid.map(_item),
            ],
          ],
        ],
      ),
    );
  }

  Widget _item(FixedExpense item) {
    return GestureDetector(
      onTap: () => onTap?.call(item.id),
      child: Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: item.isPaid ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: item.isPaid ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        border: item.isPaid ? Border.all(color: Colors.grey.shade200) : null,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onTogglePaid?.call(item.id),
            child: Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: item.isPaid ? AppColors.income : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: item.isPaid ? AppColors.income : Colors.grey.shade400, width: 1.5),
              ),
              child: item.isPaid ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (item.isPaid ? Colors.grey : AppColors.warning).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: item.isPaid ? Colors.grey : AppColors.warning, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(item.name, style: TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14,
                        decoration: item.isPaid ? TextDecoration.lineThrough : null,
                        color: item.isPaid ? Colors.grey : AppColors.textPrimary,
                      ), overflow: TextOverflow.ellipsis),
                    ),
                    if (item.isRecurring) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.repeat, size: 12, color: Colors.grey.shade400),
                    ],
                  ],
                ),
                Text(
                  'Ngày ${item.dueDay}',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Text(AppDateUtils.formatCurrency(item.amount), style: TextStyle(
            fontWeight: FontWeight.w600, fontSize: 13,
            color: item.isPaid ? Colors.grey : AppColors.expense,
            decoration: item.isPaid ? TextDecoration.lineThrough : null,
          )),
        ],
      ),
    ),
    );
  }
}
