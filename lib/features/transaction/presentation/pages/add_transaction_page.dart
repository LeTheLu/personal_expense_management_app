import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/date_utils.dart';
import 'package:du_an/di/injection.dart';
import 'package:du_an/features/transaction/data/repositories/transaction_repository.dart';
import 'package:du_an/features/budget/data/repositories/budget_repository.dart';
import 'package:du_an/features/home/data/repositories/income_source_repository.dart';
import 'package:du_an/features/saving/data/repositories/saving_repository.dart';
import 'package:du_an/features/home/data/repositories/fixed_expense_repository.dart';
import 'package:du_an/features/category/data/repositories/custom_category_repository.dart';
import 'package:du_an/features/settings/data/repositories/app_settings_repository.dart';
import 'package:du_an/features/suggestion/domain/suggestion_engine.dart';
import 'package:du_an/features/suggestion/domain/smart_parse_result.dart';
import 'package:du_an/features/transaction/domain/entities/transaction.dart';
import 'package:du_an/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:du_an/features/transaction/presentation/cubit/transaction_state.dart';
import 'package:du_an/features/transaction/presentation/widgets/smart_parse_chips.dart';
import 'package:du_an/features/transaction/presentation/widgets/smart_tag_input.dart';
import 'package:du_an/core/utils/currency_input_formatter.dart';
import 'package:intl/intl.dart';

class AddTransactionPage extends StatelessWidget {
  const AddTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransactionCubit(
        transactionRepo: getIt<TransactionRepository>(),
        budgetRepo: getIt<BudgetRepository>(),
        incomeSourceRepo: getIt<IncomeSourceRepository>(),
        savingRepo: getIt<SavingRepository>(),
        fixedExpenseRepo: getIt<FixedExpenseRepository>(),
        categoryRepo: getIt<CustomCategoryRepository>(),
        settingsRepo: getIt<AppSettingsRepository>(),
        suggestionEngine: getIt<SuggestionEngine>(),
      )..init(),
      child: const _AddTransactionView(),
    );
  }
}

class _AddTransactionView extends StatefulWidget {
  const _AddTransactionView();

  @override
  State<_AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<_AddTransactionView> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionCubit, TransactionState>(
      listener: (context, state) {
        if (state.status == TransactionFormStatus.success) {
          Navigator.pop(context, true);
        }
        if (state.status == TransactionFormStatus.needsBudgetCreation) {
          _showCreateBudgetBeforeSubmit(context, state);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Thêm giao dịch')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Zero Input Mode
                if (state.mostLikely != null) _zeroInputCard(state.mostLikely!),

                // Smart Input + Suggestions
                SmartTagInput(
                  suggestions: state.inlineSuggestions,
                  isComplete: state.smartResult != null && state.smartResult!.isComplete,
                  onTextChanged: (v) {
                    context.read<TransactionCubit>().onSmartInputChanged(v);
                  },
                ),

                const SizedBox(height: 12),

                // Smart Parse Result Chips - chỉ hiện khi có text input
                if (state.smartResult != null && state.smartInput.trim().isNotEmpty) ...[
                  GestureDetector(
                    onTap: state.smartResult!.isComplete
                        ? () => context.read<TransactionCubit>().submit()
                        : null,
                    child: SmartParseChips(
                      result: state.smartResult!,
                      onTapFund: () => _onTapUnknownFund(state.smartResult!),
                    ),
                  ),
                  if (state.smartResult!.action == SmartAction.ambiguous) _ambiguityButtons(state),
                  const SizedBox(height: 12),
                ],

                // Suggestion Chips
                if (state.suggestions.isNotEmpty && state.smartResult == null) ...[
                  _suggestionChips(state),
                  const SizedBox(height: 12),
                ],

                // Type selector (Thu nhap / Chi tieu)
                _typeSelector(state),
                const SizedBox(height: 16),

                // Income: show income sources / Expense: show categories
                if (state.type == TransactionType.income)
                  _incomeSourceSelector(state)
                else
                  _categoryGrid(state),
                const SizedBox(height: 16),

                // Amount
                _amountField(state),
                const SizedBox(height: 12),
                if (state.amountSuggestions.isNotEmpty) _amountChips(state),
                const SizedBox(height: 12),

                // Budget picker (expense only)
                if (state.type == TransactionType.expense) ...[
                  _budgetPicker(state),
                  const SizedBox(height: 12),
                ],

                // Time
                _timeSelector(state),
                const SizedBox(height: 12),

                // Note
                TextField(
                  controller: _noteCtrl,
                  onChanged: (v) => context.read<TransactionCubit>().updateNote(v),
                  decoration: InputDecoration(
                    labelText: 'Ghi chú',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: state.status == TransactionFormStatus.submitting
                        ? null
                        : () => context.read<TransactionCubit>().submit(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: state.status == TransactionFormStatus.submitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Lưu giao dịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _zeroInputCard(Suggestion suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.primaryLight.withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bạn vừa...', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text('${suggestion.label} ${AppDateUtils.formatCurrency(suggestion.amount)}?',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TransactionCubit>().applySuggestion(suggestion);
              context.read<TransactionCubit>().submit();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Đúng'),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => context.read<TransactionCubit>().applySuggestion(suggestion),
            child: const Text('Sửa'),
          ),
        ],
      ),
    );
  }

  Widget _ambiguityButtons(TransactionState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bạn muốn làm gì với ${state.smartResult?.amount != null ? AppDateUtils.formatCurrency(state.smartResult!.amount!) : "số tiền này"}?',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.read<TransactionCubit>().resolveAsAdd(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Thêm vào quỹ', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.income),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.read<TransactionCubit>().resolveAsExpense(),
                  icon: const Icon(Icons.remove, size: 16),
                  label: const Text('Chi tiêu', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.expense),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _suggestionChips(TransactionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gợi ý', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.suggestions.map((s) {
            final isTop = s.confidence >= 0.7;
            return ActionChip(
              avatar: Icon(isTop ? Icons.local_fire_department : Icons.schedule, size: 16,
                  color: isTop ? AppColors.expense : AppColors.textSecondary),
              label: Text('${s.label} ${AppDateUtils.formatCurrency(s.amount)}', style: const TextStyle(fontSize: 12)),
              backgroundColor: isTop ? AppColors.warning.withValues(alpha: 0.1) : null,
              onPressed: () {
                context.read<TransactionCubit>().applySuggestion(s);
                _amountCtrl.text = NumberFormat('#,###', 'vi_VN').format(s.amount.round());
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _typeSelector(TransactionState state) {
    final types = [TransactionType.income, TransactionType.expense];
    return Row(
      children: types.map((type) {
        final selected = state.type == type;
        final label = type == TransactionType.income ? 'Thu nhập' : 'Chi tiêu';
        final color = type == TransactionType.income ? AppColors.income : AppColors.expense;
        return Expanded(
          child: GestureDetector(
            onTap: () => context.read<TransactionCubit>().updateType(type),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? color.withValues(alpha: 0.15) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: selected ? color : Colors.transparent, width: 1.5),
              ),
              child: Center(child: Text(label, style: TextStyle(
                color: selected ? color : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal, fontSize: 14))),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _incomeSourceSelector(TransactionState state) {
    final sources = context.read<TransactionCubit>().getAllIncomeSources();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chọn nguồn thu:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...sources.map((s) {
              final selected = state.incomeSourceId == s.id;
              return GestureDetector(
                onTap: () {
                  context.read<TransactionCubit>().updateIncomeSourceId(s.id);
                  context.read<TransactionCubit>().updateCategory(s.name);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.income.withValues(alpha: 0.15) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? AppColors.income : Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(s.icon, size: 16, color: selected ? AppColors.income : Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(s.name, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          color: selected ? AppColors.income : AppColors.textPrimary)),
                    ],
                  ),
                ),
              );
            }),
            // "Khác" - create new
            GestureDetector(
              onTap: () => context.read<TransactionCubit>().updateIncomeSourceId(null),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: state.incomeSourceId == null ? AppColors.secondary.withValues(alpha: 0.15) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: state.incomeSourceId == null ? AppColors.secondary : Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline, size: 16, color: state.incomeSourceId == null ? AppColors.secondary : Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text('Khác', style: TextStyle(fontSize: 12, color: state.incomeSourceId == null ? AppColors.secondary : AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _categoryGrid(TransactionState state) {
    final cubit = context.read<TransactionCubit>();
    final categories = cubit.categoryRepo.getAll();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Danh mục:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: categories.map((cat) {
            final selected = state.category == cat.name;
            return GestureDetector(
              onTap: () => _onCategorySelected(cat.name, cat.iconCodePoint),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary.withValues(alpha: 0.15) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? AppColors.primary : Colors.transparent, width: 1.5),
                    ),
                    child: Icon(cat.icon, color: selected ? AppColors.primary : Colors.grey.shade600, size: 22),
                  ),
                  const SizedBox(height: 4),
                  Text(cat.name, style: TextStyle(fontSize: 10,
                      color: selected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _onTapUnknownFund(SmartParseResultV2 sr) async {
    final cubit = context.read<TransactionCubit>();
    final budgets = cubit.getCurrentBudgets();
    final categories = cubit.categoryRepo.getAll();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chọn quỹ cho "${sr.fundName ?? sr.category}"', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (budgets.isNotEmpty) ...[
                const Text('Quỹ có sẵn:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                ...budgets.map((b) => GestureDetector(
                  onTap: () => Navigator.pop(ctx, b.name),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                    child: Row(
                      children: [
                        Icon(b.icon, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(b.name, style: const TextStyle(fontSize: 13)),
                        const Spacer(),
                        Text(AppDateUtils.formatCurrency(b.remainingAmount > 0 ? b.remainingAmount : 0), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 8),
              ],
              if (categories.isNotEmpty) ...[
                const Text('Danh mục:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((c) => GestureDetector(
                    onTap: () => Navigator.pop(ctx, c.name),
                    child: Chip(label: Text(c.name, style: const TextStyle(fontSize: 11)), avatar: Icon(c.icon, size: 14), visualDensity: VisualDensity.compact),
                  )).toList(),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null && mounted) {
      cubit.updateCategory(result);
      // Update smart result with resolved fund
      final resolved = SmartParseResultV2(
        action: sr.action == SmartAction.createFund ? SmartAction.expense : sr.action,
        fundName: result,
        fundExists: true,
        amount: sr.amount,
        note: sr.note,
        category: result,
        confidence: 0.9,
      );
      cubit.updateSmartResult(resolved);
    }
  }

  void _onCategorySelected(String categoryName, int iconCodePoint) {
    context.read<TransactionCubit>().updateCategory(categoryName);
  }

  void _showCreateBudgetBeforeSubmit(BuildContext context, TransactionState state) {
    final category = state.pendingBudgetCategory ?? state.category;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: Text('Tạo quỹ "$category"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quỹ "$category" chưa tồn tại. Vui lòng đặt hạn mức để tạo quỹ trước khi lưu giao dịch.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Hạn mức hàng tháng',
                  suffixText: 'VND',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Reset status back to initial
                context.read<TransactionCubit>().cancelBudgetCreation();
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final limit = CurrencyInputFormatter.parse(ctrl.text);
                if (limit > 0) {
                  Navigator.pop(ctx);
                  context.read<TransactionCubit>().confirmBudgetAndSubmit(limit);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Tạo quỹ & Lưu'),
            ),
          ],
        );
      },
    );
  }

  Widget _amountField(TransactionState state) {
    return TextField(
      controller: _amountCtrl,
      keyboardType: TextInputType.number,
      inputFormatters: [CurrencyInputFormatter()],
      onChanged: (v) => context.read<TransactionCubit>().updateAmount(CurrencyInputFormatter.parse(v)),
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: 'Số tiền',
        suffixText: 'VND',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _amountChips(TransactionState state) {
    return Row(
      children: state.amountSuggestions.map((amount) => Expanded(
        child: GestureDetector(
          onTap: () {
            _amountCtrl.text = NumberFormat('#,###', 'vi_VN').format(amount.round());
            context.read<TransactionCubit>().updateAmount(amount);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(AppDateUtils.formatCurrency(amount),
                style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500))),
          ),
        ),
      )).toList(),
    );
  }

  Widget _budgetPicker(TransactionState state) {
    final budgets = context.read<TransactionCubit>().getCurrentBudgets();
    if (budgets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Trừ vào quỹ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            GestureDetector(
              onTap: () => context.read<TransactionCubit>().updateBudgetId(null),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: state.budgetId == null ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: state.budgetId == null ? AppColors.primary : Colors.grey.shade300),
                ),
                child: Text('Tự động', style: TextStyle(fontSize: 12,
                    color: state.budgetId == null ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: state.budgetId == null ? FontWeight.w600 : FontWeight.normal)),
              ),
            ),
            ...budgets.map((b) {
              final selected = state.budgetId == b.id;
              return GestureDetector(
                onTap: () => context.read<TransactionCubit>().updateBudgetId(b.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(b.icon, size: 14, color: selected ? AppColors.primary : Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(b.name, style: TextStyle(fontSize: 12, color: selected ? AppColors.primary : AppColors.textSecondary)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _timeSelector(TransactionState state) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final options = [
      {'label': 'Hôm nay', 'date': now},
      {'label': 'Hôm qua', 'date': yesterday},
      {'label': 'Chọn ngày...', 'date': null},
    ];

    return Row(
      children: options.map((opt) {
        final date = opt['date'] as DateTime?;
        final isSelected = date != null && state.date.day == date.day && state.date.month == date.month && state.date.year == date.year;
        return Expanded(
          child: GestureDetector(
            onTap: () async {
              if (date != null) {
                context.read<TransactionCubit>().updateDate(date);
              } else {
                final picked = await showDatePicker(context: context, initialDate: state.date, firstDate: DateTime(2020), lastDate: now);
                if (picked != null && context.mounted) context.read<TransactionCubit>().updateDate(picked);
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
              ),
              child: Center(child: Text(opt['label'] as String,
                  style: TextStyle(fontSize: 12, color: isSelected ? AppColors.primary : AppColors.textSecondary))),
            ),
          ),
        );
      }).toList(),
    );
  }
}
