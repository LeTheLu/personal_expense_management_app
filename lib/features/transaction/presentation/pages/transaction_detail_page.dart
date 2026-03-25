import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/date_utils.dart';
import 'package:du_an/di/injection.dart';
import 'package:du_an/features/transaction/domain/entities/transaction.dart';
import 'package:du_an/features/transaction/data/repositories/transaction_repository.dart';
import 'package:du_an/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:du_an/features/budget/data/repositories/budget_repository.dart';
import 'package:du_an/features/home/data/repositories/income_source_repository.dart';
import 'package:du_an/features/saving/data/repositories/saving_repository.dart';
import 'package:du_an/features/home/data/repositories/fixed_expense_repository.dart';
import 'package:du_an/features/category/data/repositories/custom_category_repository.dart';
import 'package:du_an/features/settings/data/repositories/app_settings_repository.dart';
import 'package:du_an/features/suggestion/domain/suggestion_engine.dart';

class TransactionDetailPage extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final categoryRepo = getIt<CustomCategoryRepository>();
    final cat = categoryRepo.getByName(transaction.category);
    final icon = cat?.icon ?? Icons.more_horiz;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết giao dịch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _onDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${isIncome ? '+' : '-'} ${AppDateUtils.formatCurrency(transaction.amount)}',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(isIncome ? 'Thu nhập' : 'Chi tiêu', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                ],
              ),
            ),

            // Details
            _detailRow(Icons.category, 'Danh mục', transaction.category),
            if (transaction.note != null) _detailRow(Icons.note, 'Ghi chú', transaction.note!),
            _detailRow(Icons.access_time, 'Thời gian', AppDateUtils.formatDateTime(transaction.date)),
            if (transaction.budgetId != null) _detailRow(Icons.account_balance_wallet, 'Quỹ', transaction.budgetId!),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const Spacer(),
          Flexible(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  void _onDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa giao dịch'),
        content: const Text('Giao dịch sẽ bị xóa và tiền sẽ được hoàn trả vào quỹ tương ứng.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final cubit = TransactionCubit(
        transactionRepo: getIt<TransactionRepository>(),
        budgetRepo: getIt<BudgetRepository>(),
        incomeSourceRepo: getIt<IncomeSourceRepository>(),
        savingRepo: getIt<SavingRepository>(),
        fixedExpenseRepo: getIt<FixedExpenseRepository>(),
        categoryRepo: getIt<CustomCategoryRepository>(),
        settingsRepo: getIt<AppSettingsRepository>(),
        suggestionEngine: getIt<SuggestionEngine>(),
      );
      await cubit.deleteTransaction(transaction);
      if (context.mounted) Navigator.pop(context, true);
    }
  }
}
