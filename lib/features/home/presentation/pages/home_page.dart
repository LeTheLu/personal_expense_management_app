import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:du_an/core/widgets/loading_widget.dart';
import 'package:du_an/features/home/presentation/cubit/home_cubit.dart';
import 'package:du_an/features/home/presentation/cubit/home_state.dart';
import 'package:du_an/features/home/presentation/widgets/home_calendar.dart';
import 'package:du_an/features/home/presentation/widgets/payment_schedule.dart';
// import 'package:du_an/features/home/presentation/widgets/total_assets_card.dart';
import 'package:du_an/features/home/presentation/widgets/balance_card.dart';
import 'package:du_an/features/home/presentation/widgets/budget_section.dart';
import 'package:du_an/features/home/presentation/widgets/saving_section.dart';
import 'package:du_an/features/home/presentation/widgets/fixed_expense_section.dart';
import 'package:du_an/features/home/presentation/widgets/add_income_dialog.dart';
import 'package:du_an/features/home/domain/entities/income_source.dart';
import 'package:du_an/features/home/presentation/pages/income_source_detail_page.dart';
import 'package:du_an/features/saving/presentation/pages/saving_detail_page.dart';
import 'package:du_an/features/budget/presentation/pages/budget_detail_page.dart';
import 'package:du_an/core/widgets/income_source_picker.dart';
import 'package:du_an/features/budget/presentation/widgets/add_budget_dialog.dart';
import 'package:du_an/features/home/presentation/widgets/recent_transactions.dart';
import 'package:du_an/features/home/presentation/widgets/add_item_dialog.dart';
import 'package:du_an/features/home/presentation/widgets/add_fixed_expense_dialog.dart';
import 'package:du_an/features/home/presentation/pages/fixed_expense_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // HomeCubit is provided by MainShell
    return const _HomeView();
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý chi tiêu')),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.status == HomeStatus.loading) return const LoadingWidget();

          return RefreshIndicator(
            onRefresh: () async => context.read<HomeCubit>().load(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // 1. Calendar
                  HomeCalendar(
                    month: state.selectedMonth,
                    year: state.selectedYear,
                    salaryDay: state.salaryDay,
                    fixedExpenses: state.fixedExpenses,
                    onPrevMonth: () => context.read<HomeCubit>().prevMonth(),
                    onNextMonth: () => context.read<HomeCubit>().nextMonth(),
                  ),
                  const SizedBox(height: 12),

                  // 2. Payment + Income Schedule
                  PaymentSchedule(
                    fixedExpenses: state.fixedExpenses,
                    salaryDay: state.salaryDay,
                  ),
                  //const SizedBox(height: 12),

                  // 3. Total Balance + Income/Expense
                  // TotalAssetsCard(
                  //   totalBalance: state.balance,
                  //   totalIncome: state.totalIncome,
                  //   totalExpense: state.totalExpense,
                  // ),
                  // const SizedBox(height: 12),

                  // 4. Income Sources
                  BalanceCard(
                    balance: state.balance,
                    totalIncome: state.totalIncome,
                    totalExpense: state.totalExpense,
                    incomeSources: state.incomeSources,
                    onAddIncome: () => _showAddIncomeDialog(context),
                    onTapIncome: (source) => _openIncomeDetail(context, source),
                  ),

                  // 5. Savings
                  SavingSection(
                    savings: state.savings,
                    totalSaved: state.totalSaved,
                    onAdd: () => _showAddDialog(
                      context,
                      title: 'Thêm mục tiêu tích lũy',
                      amountLabel: 'Mục tiêu',
                      icons: const [Icons.savings, Icons.flight, Icons.directions_car, Icons.home, Icons.school, Icons.laptop],
                      onResult: (r) => context.read<HomeCubit>().addSaving(
                            name: r['name'] as String,
                            targetAmount: r['amount'] as double,
                            icon: r['icon'] as IconData,
                          ),
                    ),
                    onTap: (id) => _openSavingDetail(context, id),
                  ),
                  const SizedBox(height: 16),

                  // 6. Budgets
                  BudgetSection(
                    budgets: state.budgets,
                    onAdd: () => _showAddBudgetDialog(context),
                    onDelete: (id) => context.read<HomeCubit>().deleteBudget(id),
                    onTap: (id) => _openBudgetDetail(context, id),
                  ),
                  const SizedBox(height: 16),

                  // 7. Fixed Expenses
                  FixedExpenseSection(
                    fixedExpenses: state.fixedExpenses,
                    onTogglePaid: (id) => _onToggleFixedExpense(context, id, state),
                    onAdd: () => _showAddFixedExpenseDialog(context),
                    onTap: (id) => _openFixedExpenseDetail(context, id),
                  ),
                  const SizedBox(height: 16),

                  // 8. Recent Transactions
                  RecentTransactions(
                    transactions: state.recentTransactions,
                    onRefresh: () => context.read<HomeCubit>().load(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddIncomeDialog(BuildContext context) async {
    final cubit = context.read<HomeCubit>();
    final existingSources = cubit.getExistingIncomeSources();
    final result = await showDialog<AddIncomeResult>(
      context: context,
      builder: (_) => AddIncomeDialog(existingSources: existingSources),
    );
    if (result != null && context.mounted) {
      if (result.isNew) {
        cubit.addIncomeSource(name: result.name!, amount: result.amount, icon: result.icon!);
      } else {
        cubit.addToIncomeSource(result.existingId!, result.amount);
      }
    }
  }

  void _openIncomeDetail(BuildContext context, IncomeSource source) async {
    final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => IncomeSourceDetailPage(incomeSourceId: source.id)));
    if (result == true && context.mounted) context.read<HomeCubit>().load();
  }

  void _openSavingDetail(BuildContext context, String savingId) async {
    final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => SavingDetailPage(savingId: savingId)));
    if (result == true && context.mounted) context.read<HomeCubit>().load();
  }

  void _onToggleFixedExpense(BuildContext context, String id, HomeState state) async {
    final item = state.fixedExpenses.where((f) => f.id == id).firstOrNull;
    if (item == null) return;
    if (item.isPaid) {
      context.read<HomeCubit>().toggleFixedExpensePaid(id);
      return;
    }
    final sources = context.read<HomeCubit>().getAllIncomeSources();
    if (sources.isEmpty) {
      context.read<HomeCubit>().toggleFixedExpensePaid(id);
      return;
    }
    final sourceId = await showDialog<String>(
      context: context,
      builder: (_) => IncomeSourcePicker(sources: sources, amount: item.amount, title: 'Trả "${item.name}" từ nguồn nào?'),
    );
    if (sourceId != null && context.mounted) {
      context.read<HomeCubit>().toggleFixedExpensePaid(id, incomeSourceId: sourceId);
    }
  }

  void _openFixedExpenseDetail(BuildContext context, String id) async {
    final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => FixedExpenseDetailPage(fixedExpenseId: id)));
    if (result == true && context.mounted) context.read<HomeCubit>().load();
  }

  void _showAddFixedExpenseDialog(BuildContext context) async {
    final result = await showDialog<AddFixedExpenseResult>(
      context: context,
      builder: (_) => const AddFixedExpenseDialog(),
    );
    if (result != null && context.mounted) {
      context.read<HomeCubit>().addFixedExpense(
            name: result.name,
            amount: result.amount,
            icon: result.icon,
            dueDay: result.dueDay,
            isRecurring: result.isRecurring,
          );
    }
  }

  void _showAddBudgetDialog(BuildContext context) async {
    final sources = context.read<HomeCubit>().getAllIncomeSources();
    final result = await showDialog<AddBudgetResult>(context: context, builder: (_) => AddBudgetDialog(incomeSources: sources));
    if (result != null && context.mounted) {
      context.read<HomeCubit>().addBudget(
            name: result.name, limitAmount: result.limitAmount, icon: result.icon, preferredIncomeSourceId: result.preferredIncomeSourceId);
    }
  }

  void _openBudgetDetail(BuildContext context, String budgetId) async {
    final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => BudgetDetailPage(budgetId: budgetId)));
    if (result == true && context.mounted) context.read<HomeCubit>().load();
  }

  void _showAddDialog(BuildContext context, {required String title, required List<IconData> icons, String amountLabel = 'Số tiền',
      required void Function(Map<String, dynamic>) onResult}) async {
    final result = await showDialog<Map<String, dynamic>>(context: context, builder: (_) => AddItemDialog(title: title, icons: icons, amountLabel: amountLabel));
    if (result != null && context.mounted) onResult(result);
  }
}
