import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/date_utils.dart';
import 'package:du_an/features/budget/domain/entities/budget.dart';

class BudgetSection extends StatelessWidget {
  final List<Budget> budgets;
  final VoidCallback? onAdd;
  final ValueChanged<String>? onDelete;
  final ValueChanged<String>? onTap;

  const BudgetSection({super.key, required this.budgets, this.onAdd, this.onDelete, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quỹ chi tiêu', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (budgets.isEmpty)
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
                  Icon(Icons.pie_chart_outline, color: Colors.grey.shade400, size: 32),
                  const SizedBox(height: 8),
                  Text('Chưa có quỹ chi tiêu', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                ],
              ),
            )
          else
            ...budgets.map(_budgetItem),
        ],
      ),
    );
  }

  Widget _budgetItem(Budget budget) {
    final isOver = budget.isOverBudget;
    final color = isOver ? AppColors.expense : AppColors.primary;

    return GestureDetector(
      onTap: () => onTap?.call(budget.id),
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(budget.icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(budget.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(
                      'Còn lại: ${AppDateUtils.formatCurrency(budget.remainingAmount > 0 ? budget.remainingAmount : 0)}',
                      style: TextStyle(color: isOver ? AppColors.expense : AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(AppDateUtils.formatCurrency(budget.spentAmount),
                      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('/ ${AppDateUtils.formatCurrency(budget.limitAmount)}',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: budget.progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    ),
    );
  }
}
