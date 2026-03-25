import 'package:equatable/equatable.dart';
import 'package:du_an/features/transaction/domain/entities/transaction.dart';
import 'package:du_an/features/home/domain/entities/income_source.dart';
import 'package:du_an/features/home/domain/entities/fixed_expense.dart';
import 'package:du_an/features/budget/domain/entities/budget.dart';
import 'package:du_an/features/saving/domain/entities/saving.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final double totalIncome;
  final double totalExpense;
  final List<IncomeSource> incomeSources;
  final List<Budget> budgets;
  final List<FixedExpense> fixedExpenses;
  final List<Saving> savings;
  final List<TransactionEntity> recentTransactions;
  final double totalSaved;
  final int selectedMonth;
  final int selectedYear;
  final int salaryDay;
  final String? errorMessage;

  HomeState({
    this.status = HomeStatus.initial,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.incomeSources = const [],
    this.budgets = const [],
    this.fixedExpenses = const [],
    this.savings = const [],
    this.recentTransactions = const [],
    this.totalSaved = 0,
    int? selectedMonth,
    int? selectedYear,
    this.salaryDay = 1,
    this.errorMessage,
  })  : selectedMonth = selectedMonth ?? DateTime.now().month,
        selectedYear = selectedYear ?? DateTime.now().year;

  double get balance {
    // Total remaining from all income sources
    return incomeSources.fold(0.0, (sum, s) => sum + s.remainingAmount);
  }

  double get totalAssets {
    final incomeRemaining = incomeSources.fold(0.0, (sum, s) => sum + s.remainingAmount);
    final savingTotal = savings.fold(0.0, (sum, s) => sum + s.currentAmount);
    return incomeRemaining + savingTotal;
  }

  double get totalAllocated {
    double allocated = 0;
    for (final b in budgets) allocated += b.limitAmount;
    for (final f in fixedExpenses) allocated += f.amount;
    return allocated;
  }

  HomeState copyWith({
    HomeStatus? status,
    double? totalIncome,
    double? totalExpense,
    List<IncomeSource>? incomeSources,
    List<Budget>? budgets,
    List<FixedExpense>? fixedExpenses,
    List<Saving>? savings,
    List<TransactionEntity>? recentTransactions,
    double? totalSaved,
    int? selectedMonth,
    int? selectedYear,
    int? salaryDay,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      incomeSources: incomeSources ?? this.incomeSources,
      budgets: budgets ?? this.budgets,
      fixedExpenses: fixedExpenses ?? this.fixedExpenses,
      savings: savings ?? this.savings,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      totalSaved: totalSaved ?? this.totalSaved,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      salaryDay: salaryDay ?? this.salaryDay,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status, totalIncome, totalExpense, incomeSources, budgets,
        fixedExpenses, savings, recentTransactions, totalSaved,
        selectedMonth, selectedYear, salaryDay, errorMessage,
      ];
}
