import 'package:du_an/core/widgets/expandable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/date_utils.dart';
import 'package:du_an/features/home/domain/entities/income_source.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final List<IncomeSource> incomeSources;
  final VoidCallback? onAddIncome;
  final void Function(IncomeSource)? onTapIncome;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    this.incomeSources = const [],
    this.onAddIncome,
    this.onTapIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng số dư', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    if (onAddIncome != null)
                      GestureDetector(
                        onTap: onAddIncome,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 18),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppDateUtils.formatCurrency(balance),
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _summaryItem(Icons.arrow_downward, 'Thu nhập', totalIncome, Colors.greenAccent),
                    _summaryItem(Icons.arrow_upward, 'Chi tiêu', totalExpense, Colors.redAccent),
                  ],
                ),
              ],
            ),
          ),
          if (incomeSources.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: ExpandableDropdown(
                title: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, color: AppColors.primaryDark, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Nguồn thu (${incomeSources.length})',
                      style: const TextStyle(color: AppColors.primaryDark, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                items: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      children: incomeSources.map((s) => _incomeSourceItem(s)).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _incomeSourceItem(IncomeSource s) {
    final color = s.isOverSpent ? AppColors.expense : AppColors.income;

    return GestureDetector(
      onTap: () => onTapIncome?.call(s),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.income.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(s.icon, color: AppColors.income, size: 14),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      Text(
                        'Còn: ${AppDateUtils.formatCurrency(s.remainingAmount > 0 ? s.remainingAmount : 0)}',
                        style: TextStyle(fontSize: 10, color: s.isOverSpent ? AppColors.expense : AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppDateUtils.formatCurrency(s.amount),
                      style: const TextStyle(color: AppColors.income, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    if (s.spentAmount > 0)
                      Text(
                        'Đã dùng: ${AppDateUtils.formatCurrency(s.spentAmount)}',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                      ),
                  ],
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade400),
              ],
            ),
            if (s.spentAmount > 0) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: s.progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(IconData icon, String label, double amount, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(AppDateUtils.formatCurrency(amount), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
