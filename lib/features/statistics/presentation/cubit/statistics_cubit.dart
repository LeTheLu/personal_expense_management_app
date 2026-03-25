import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:du_an/features/transaction/data/repositories/transaction_repository.dart';
import 'package:du_an/features/statistics/presentation/cubit/statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final TransactionRepository transactionRepo;

  StatisticsCubit({required this.transactionRepo}) : super(const StatisticsState());

  void loadStatistics() {
    emit(state.copyWith(status: StatisticsStatus.loading));
    try {
      final now = DateTime.now();
      final income = transactionRepo.getTotalIncome(now.month, now.year);
      final expense = transactionRepo.getTotalExpense(now.month, now.year);
      final breakdown = transactionRepo.getCategoryBreakdown(now.month, now.year);

      final categoryData = breakdown.entries.map((e) {
        return CategoryData(
          category: e.key,
          amount: e.value,
          percentage: expense > 0 ? (e.value / expense) * 100 : 0,
        );
      }).toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));

      emit(state.copyWith(
        status: StatisticsStatus.loaded,
        totalIncome: income,
        totalExpense: expense,
        categoryBreakdown: categoryData,
      ));
    } catch (e) {
      emit(state.copyWith(status: StatisticsStatus.error, errorMessage: e.toString()));
    }
  }
}
