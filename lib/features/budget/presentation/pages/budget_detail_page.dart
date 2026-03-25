import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/date_utils.dart';
import 'package:du_an/di/injection.dart';
import 'package:du_an/features/budget/domain/entities/budget.dart';
import 'package:du_an/features/budget/domain/entities/budget_history.dart';
import 'package:du_an/features/budget/data/repositories/budget_repository.dart';
import 'package:du_an/features/transaction/data/repositories/transaction_repository.dart';
import 'package:du_an/features/transaction/domain/entities/transaction.dart';
import 'package:du_an/features/budget/presentation/widgets/edit_budget_dialog.dart';
import 'package:du_an/features/home/data/repositories/income_source_repository.dart';
import 'package:du_an/core/widgets/rich_history_item.dart';

class BudgetDetailPage extends StatefulWidget {
  final String budgetId;

  const BudgetDetailPage({super.key, required this.budgetId});

  @override
  State<BudgetDetailPage> createState() => _BudgetDetailPageState();
}

class _BudgetDetailPageState extends State<BudgetDetailPage> {
  final _budgetRepo = getIt<BudgetRepository>();
  final _transactionRepo = getIt<TransactionRepository>();
  final _incomeRepo = getIt<IncomeSourceRepository>();
  Budget? _budget;
  List<BudgetHistoryEntry> _history = [];
  List<TransactionEntity> _transactions = [];
  bool _deleted = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _budget = _budgetRepo.getById(widget.budgetId);
      _history = _budgetRepo.getHistory(widget.budgetId);
      _transactions = _transactionRepo.getByBudgetId(widget.budgetId);
      // Also get transactions matching budget name as category
      if (_budget != null) {
        final byCategory = _transactionRepo.getByCategory(_budget!.name)
            .where((t) => t.type == TransactionType.expense)
            .toList();
        // Merge, deduplicate
        final ids = _transactions.map((t) => t.id).toSet();
        for (final t in byCategory) {
          if (!ids.contains(t.id)) _transactions.add(t);
        }
        _transactions.sort((a, b) => b.date.compareTo(a.date));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_deleted || _budget == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quỹ chi tiêu')),
        body: const Center(child: Text('Quỹ đã bị xóa')),
      );
    }

    final budget = _budget!;
    final isOver = budget.isOverBudget;
    final color = isOver ? AppColors.expense : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết quỹ chi tiêu'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _onEdit(budget)),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _onDelete(budget)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                    child: Icon(budget.icon, color: color, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(budget.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppDateUtils.formatCurrency(budget.spentAmount),
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                      Text(' / ${AppDateUtils.formatCurrency(budget.limitAmount)}',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: budget.progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${(budget.progress * 100).toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                      Text(
                        isOver
                            ? 'Vượt ${AppDateUtils.formatCurrency(budget.spentAmount - budget.limitAmount)}'
                            : 'Còn lại: ${AppDateUtils.formatCurrency(budget.remainingAmount)}',
                        style: TextStyle(fontSize: 12, color: isOver ? AppColors.expense : Colors.grey.shade600),
                      ),
                    ],
                  ),
                  if (isOver) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.expense.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Vượt hạn mức!', style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ),

            // Transactions linked to this budget
            if (_transactions.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text('Giao dịch (${_transactions.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _transactions.length,
                itemBuilder: (context, index) => _transactionItem(_transactions[index]),
              ),
              const SizedBox(height: 16),
            ],

            // History
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.history, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text('Lịch sử (${_history.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (_history.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('Chưa có lịch sử', style: TextStyle(color: Colors.grey.shade500, fontSize: 13))),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final entry = _history[index];
                  return RichHistoryItem(
                    action: entry.action,
                    description: entry.description,
                    oldAmount: entry.oldAmount,
                    newAmount: entry.newAmount,
                    date: entry.date,
                    isFirst: index == 0,
                    isLast: index == _history.length - 1,
                  );
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _transactionItem(TransactionEntity t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.expense.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.remove, color: AppColors.expense, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.note ?? t.category, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text(AppDateUtils.formatDateTime(t.date), style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Text('-${AppDateUtils.formatCurrency(t.amount)}',
              style: const TextStyle(color: AppColors.expense, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  void _onEdit(Budget budget) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => EditBudgetDialog(budget: budget, incomeSources: _incomeRepo.getAll()),
    );
    if (result != null) {
      final updated = Budget(
        id: budget.id,
        name: result['name'] as String,
        limitAmount: result['limitAmount'] as double,
        spentAmount: budget.spentAmount,
        month: budget.month,
        year: budget.year,
        iconCodePoint: result['iconCodePoint'] as int,
        preferredIncomeSourceId: result['preferredIncomeSourceId'] as String?,
      );
      await _budgetRepo.update(updated);
      _loadData();
    }
  }

  void _onDelete(Budget budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa quỹ chi tiêu'),
        content: Text('Bạn có chắc muốn xóa "${budget.name}"?'),
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
    if (confirmed == true && mounted) {
      await _budgetRepo.delete(budget.id);
      setState(() => _deleted = true);
      if (mounted) Navigator.pop(context, true);
    }
  }
}
