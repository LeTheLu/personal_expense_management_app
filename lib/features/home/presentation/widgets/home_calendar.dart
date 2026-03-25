import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/features/home/domain/entities/fixed_expense.dart';

class HomeCalendar extends StatelessWidget {
  final int month;
  final int year;
  final int salaryDay;
  final List<FixedExpense> fixedExpenses;
  final VoidCallback? onPrevMonth;
  final VoidCallback? onNextMonth;

  const HomeCalendar({
    super.key,
    required this.month,
    required this.year,
    this.salaryDay = 1,
    this.fixedExpenses = const [],
    this.onPrevMonth,
    this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDay.weekday; // 1=Mon, 7=Sun

    // Map due dates to icons
    final dueDateIcons = <int, List<FixedExpense>>{};
    for (final fe in fixedExpenses) {
      if (fe.dueDate.month == month && fe.dueDate.year == year) {
        dueDateIcons.putIfAbsent(fe.dueDate.day, () => []).add(fe);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Month header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: onPrevMonth, icon: const Icon(Icons.chevron_left, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              Text(
                'Tháng $month, $year',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: onNextMonth, icon: const Icon(Icons.chevron_right, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            ],
          ),
          const SizedBox(height: 8),

          // Weekday headers
          Row(
            children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'].map((d) => Expanded(
              child: Center(child: Text(d, style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600))),
            )).toList(),
          ),
          const SizedBox(height: 4),

          // Days grid
          ...List.generate(6, (weekIndex) {
            return Row(
              children: List.generate(7, (dayIndex) {
                final dayNum = weekIndex * 7 + dayIndex + 1 - (startWeekday - 1);
                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 36));
                }

                final isToday = now.day == dayNum && now.month == month && now.year == year;
                final isSalary = dayNum == salaryDay;
                final hasDue = dueDateIcons.containsKey(dayNum);

                return Expanded(
                  child: Container(
                    height: 36,
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '$dayNum',
                          style: TextStyle(
                            fontSize: 12,
                            color: isToday ? Colors.white : AppColors.textPrimary,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        // Salary indicator
                        if (isSalary)
                          Positioned(
                            bottom: 2,
                            child: Container(
                              width: 4, height: 4,
                              decoration: const BoxDecoration(color: AppColors.income, shape: BoxShape.circle),
                            ),
                          ),
                        // Due date indicator - show icon
                        if (hasDue)
                          Positioned(
                            top: 1,
                            right: 1,
                            child: Icon(
                              dueDateIcons[dayNum]!.first.icon,
                              size: 8,
                              color: dueDateIcons[dayNum]!.any((f) => !f.isPaid) ? AppColors.expense : AppColors.income,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}
