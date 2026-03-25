import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/date_utils.dart';

class TotalAssetsCard extends StatelessWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;

  const TotalAssetsCard({
    super.key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            const Text('Tổng số dư', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              AppDateUtils.formatCurrency(totalBalance),
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniStat(Icons.arrow_downward, 'Thu nhập', totalIncome, Colors.greenAccent),
                _miniStat(Icons.arrow_upward, 'Chi tiêu', totalExpense, Colors.redAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String label, double amount, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            Text(AppDateUtils.formatCurrency(amount), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
