import 'package:equatable/equatable.dart';

enum StatisticsStatus { initial, loading, loaded, error }

class CategoryData {
  final String category;
  final double amount;
  final double percentage;

  const CategoryData({required this.category, required this.amount, required this.percentage});
}

class StatisticsState extends Equatable {
  final StatisticsStatus status;
  final double totalIncome;
  final double totalExpense;
  final List<CategoryData> categoryBreakdown;
  final String? errorMessage;

  const StatisticsState({
    this.status = StatisticsStatus.initial,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.categoryBreakdown = const [],
    this.errorMessage,
  });

  double get balance => totalIncome - totalExpense;

  StatisticsState copyWith({
    StatisticsStatus? status,
    double? totalIncome,
    double? totalExpense,
    List<CategoryData>? categoryBreakdown,
    String? errorMessage,
  }) {
    return StatisticsState(
      status: status ?? this.status,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, totalIncome, totalExpense, categoryBreakdown, errorMessage];
}
