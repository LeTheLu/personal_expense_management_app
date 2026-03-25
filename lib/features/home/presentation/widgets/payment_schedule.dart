import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/features/home/domain/entities/fixed_expense.dart';

class PaymentSchedule extends StatelessWidget {
  final List<FixedExpense> fixedExpenses;
  final int salaryDay;

  const PaymentSchedule({super.key, required this.fixedExpenses, this.salaryDay = 1});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final unpaid = fixedExpenses.where((f) => !f.isPaid).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    // Salary countdown
    var nextSalary = DateTime(now.year, now.month, salaryDay);
    if (nextSalary.isBefore(now) || nextSalary.isAtSameMomentAs(now)) {
      nextSalary = DateTime(now.year, now.month + 1, salaryDay);
    }
    final salaryDaysLeft = nextSalary.difference(now).inDays;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment schedule
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lịch thanh toán', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (unpaid.isEmpty)
                    Text('Đã thanh toán hết', style: TextStyle(fontSize: 11, color: Colors.grey.shade500))
                  else
                    ...unpaid.take(3).map((f) {
                      final daysLeft = f.dueDate.difference(now).inDays;
                      final isOverdue = daysLeft < 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(f.icon, size: 14, color: isOverdue ? AppColors.expense : AppColors.warning),
                            const SizedBox(width: 6),
                            Expanded(child: Text(f.name, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isOverdue ? AppColors.expense : AppColors.warning).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isOverdue ? 'Quá hạn' : '$daysLeft ngày',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
                                    color: isOverdue ? AppColors.expense : AppColors.warning),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Income schedule
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lịch thu nhập', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, size: 14, color: AppColors.income),
                      const SizedBox(width: 6),
                      const Expanded(child: Text('Nhận lương', style: TextStyle(fontSize: 11))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.income.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$salaryDaysLeft ngày',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.income),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
