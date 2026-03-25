import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/date_utils.dart';
import 'package:du_an/di/injection.dart';
import 'package:du_an/features/transaction/domain/entities/transaction.dart';
import 'package:du_an/features/category/data/repositories/custom_category_repository.dart';
import 'package:du_an/features/transaction/presentation/pages/transaction_detail_page.dart';

class RecentTransactions extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final VoidCallback? onRefresh;

  const RecentTransactions({super.key, required this.transactions, this.onRefresh});

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
              Text('Giao dịch gần đây', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('Xem tất cả')),
            ],
          ),
          if (transactions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, color: Colors.grey.shade400, size: 40),
                  const SizedBox(height: 8),
                  Text('Chưa có giao dịch nào', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: transactions.map((t) => _transactionItem(context, t)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _transactionItem(BuildContext context, TransactionEntity t) {
    final isIncome = t.type == TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final categoryRepo = getIt<CustomCategoryRepository>();
    final cat = categoryRepo.getByName(t.category);
    final icon = cat?.icon ?? Icons.more_horiz;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => TransactionDetailPage(transaction: t)),
        );
        if (result == true) onRefresh?.call();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                t.note ?? t.category,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'} ${AppDateUtils.formatCurrency(t.amount)}',
                  style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(AppDateUtils.formatDate(t.date), style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
