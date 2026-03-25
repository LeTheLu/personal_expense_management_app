import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:du_an/features/transaction/data/repositories/transaction_repository.dart';
import 'package:du_an/features/home/data/repositories/income_source_repository.dart';
import 'package:du_an/features/home/data/repositories/fixed_expense_repository.dart';
import 'package:du_an/features/budget/data/repositories/budget_repository.dart';
import 'package:du_an/features/saving/data/repositories/saving_repository.dart';
import 'package:du_an/features/home/domain/entities/income_source.dart';
import 'package:du_an/features/home/domain/entities/fixed_expense.dart';
import 'package:du_an/features/budget/domain/entities/budget.dart';
import 'package:du_an/features/saving/domain/entities/saving.dart';
import 'package:du_an/features/settings/data/repositories/app_settings_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final TransactionRepository transactionRepo;
  final IncomeSourceRepository incomeSourceRepo;
  final FixedExpenseRepository fixedExpenseRepo;
  final BudgetRepository budgetRepo;
  final SavingRepository savingRepo;
  final AppSettingsRepository settingsRepo;

  HomeCubit({
    required this.transactionRepo,
    required this.incomeSourceRepo,
    required this.fixedExpenseRepo,
    required this.budgetRepo,
    required this.savingRepo,
    required this.settingsRepo,
  }) : super(HomeState());

  void load() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      // Auto-generate recurring fixed expenses
      await generateRecurringFixedExpenses();

      final month = state.selectedMonth;
      final year = state.selectedYear;
      final settings = settingsRepo.get();

      final totalIncome = transactionRepo.getTotalIncome(month, year);
      final totalExpense = transactionRepo.getTotalExpense(month, year);
      final incomeSources = incomeSourceRepo.getByMonth(month, year);
      final budgets = budgetRepo.getByMonth(month, year);
      final fixedExpenses = fixedExpenseRepo.getByMonth(month, year);
      final savings = savingRepo.getAll();
      final recent = transactionRepo.getRecent(limit: 5);
      final totalSaved = savingRepo.getTotalSaved();

      emit(state.copyWith(
        status: HomeStatus.loaded,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        incomeSources: incomeSources,
        budgets: budgets,
        fixedExpenses: fixedExpenses,
        savings: savings,
        recentTransactions: recent,
        totalSaved: totalSaved,
        salaryDay: settings.salaryDay,
      ));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.error, errorMessage: e.toString()));
    }
  }

  // Income Sources
  Future<void> addIncomeSource({required String name, required double amount, required IconData icon}) async {
    final source = IncomeSource(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      amount: amount,
      date: DateTime.now(),
      iconCodePoint: icon.codePoint,
    );
    await incomeSourceRepo.add(source);
    load();
  }

  Future<void> addToIncomeSource(String id, double amount) async {
    await incomeSourceRepo.addAmount(id, amount);
    load();
  }

  List<IncomeSource> getExistingIncomeSources() {
    return incomeSourceRepo.getUniqueByName();
  }

  Future<void> updateIncomeSource({required String id, required String name, required double amount, required int iconCodePoint}) async {
    final source = IncomeSource(
      id: id,
      name: name,
      amount: amount,
      date: DateTime.now(),
      iconCodePoint: iconCodePoint,
    );
    await incomeSourceRepo.update(source);
    load();
  }

  Future<void> deleteIncomeSource(String id) async {
    await incomeSourceRepo.delete(id);
    load();
  }

  // Budgets
  Future<void> addBudget({required String name, required double limitAmount, required IconData icon, String? preferredIncomeSourceId}) async {
    final now = DateTime.now();
    final budget = Budget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      limitAmount: limitAmount,
      month: now.month,
      year: now.year,
      iconCodePoint: icon.codePoint,
      preferredIncomeSourceId: preferredIncomeSourceId,
    );
    await budgetRepo.add(budget);
    load();
  }

  Future<void> deleteBudget(String id) async {
    await budgetRepo.delete(id);
    load();
  }

  // Fixed Expenses
  Future<void> addFixedExpense({
    required String name,
    required double amount,
    required IconData icon,
    int dueDay = 1,
    bool isRecurring = false,
  }) async {
    final now = DateTime.now();
    final dueDate = DateTime(now.year, now.month, dueDay.clamp(1, 31));
    final item = FixedExpense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      amount: amount,
      dueDate: dueDate,
      iconCodePoint: icon.codePoint,
      isRecurring: isRecurring,
      dueDay: dueDay,
    );
    await fixedExpenseRepo.add(item);
    load();
  }

  /// Auto-create recurring fixed expenses for new month
  Future<void> generateRecurringFixedExpenses() async {
    final now = DateTime.now();
    final existing = fixedExpenseRepo.getByMonth(now.month, now.year);
    final allRecurring = fixedExpenseRepo.getAll().where((f) => f.isRecurring);

    for (final recurring in allRecurring) {
      final alreadyExists = existing.any((e) => e.name == recurring.name && e.dueDate.month == now.month);
      if (!alreadyExists) {
        final newItem = FixedExpense(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: recurring.name,
          amount: recurring.amount,
          dueDate: DateTime(now.year, now.month, recurring.dueDay.clamp(1, 31)),
          iconCodePoint: recurring.iconCodePoint,
          isRecurring: true,
          dueDay: recurring.dueDay,
        );
        await fixedExpenseRepo.add(newItem);
      }
    }
  }

  Future<void> toggleFixedExpensePaid(String id, {String? incomeSourceId}) async {
    final item = fixedExpenseRepo.getByMonth(DateTime.now().month, DateTime.now().year)
        .where((f) => f.id == id).firstOrNull;
    if (item == null) return;

    if (!item.isPaid) {
      // Marking as paid → deduct from income source
      await fixedExpenseRepo.togglePaid(id, paidFrom: incomeSourceId);
      if (incomeSourceId != null) {
        await incomeSourceRepo.deductAmount(
          incomeSourceId,
          item.amount,
          description: 'Chi phí cố định "${item.name}" - ${item.amount}',
        );
      }
    } else {
      // Unmarking (untick) → refund back to the original source
      if (item.paidFrom != null) {
        await incomeSourceRepo.refundAmount(
          item.paidFrom!,
          item.amount,
          description: 'Hoàn trả chi phí cố định "${item.name}" +${item.amount}',
        );
      }
      await fixedExpenseRepo.togglePaid(id);
    }
    load();
  }

  List<IncomeSource> getAllIncomeSources() => incomeSourceRepo.getAll();

  // Savings
  Future<void> addSaving({required String name, required double targetAmount, required IconData icon}) async {
    final saving = Saving(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      targetAmount: targetAmount,
      createdAt: DateTime.now(),
      iconCodePoint: icon.codePoint,
    );
    await savingRepo.add(saving);
    load();
  }

  Future<void> addToSaving(String id, double amount) async {
    await savingRepo.addAmount(id, amount);
    load();
  }

  Future<void> deleteSaving(String id) async {
    await savingRepo.delete(id);
    load();
  }

  // Calendar navigation
  void prevMonth() {
    var m = state.selectedMonth - 1;
    var y = state.selectedYear;
    if (m < 1) { m = 12; y--; }
    emit(state.copyWith(selectedMonth: m, selectedYear: y));
    load();
  }

  void nextMonth() {
    var m = state.selectedMonth + 1;
    var y = state.selectedYear;
    if (m > 12) { m = 1; y++; }
    emit(state.copyWith(selectedMonth: m, selectedYear: y));
    load();
  }
}
