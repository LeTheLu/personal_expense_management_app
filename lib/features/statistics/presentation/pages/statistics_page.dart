import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/constants/app_icons.dart';
import 'package:du_an/core/constants/app_images.dart';
import 'package:du_an/core/utils/date_utils.dart';
import 'package:du_an/core/widgets/loading_widget.dart';
import 'package:du_an/di/injection.dart';
import 'package:du_an/features/transaction/data/repositories/transaction_repository.dart';
import 'package:du_an/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:du_an/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:du_an/features/statistics/presentation/widgets/category_bar.dart';
import 'package:du_an/features/statistics/presentation/widgets/summary_card.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StatisticsCubit(transactionRepo: getIt<TransactionRepository>())..loadStatistics(),
      child: const _StatisticsView(),
    );
  }
}

class _StatisticsView extends StatelessWidget {
  const _StatisticsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê'),
        actions: [
          IconButton(
            icon: SvgPicture.asset(AppIcons.stats, width: 24, height: 24,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) {
          if (state.status == StatisticsStatus.loading) return const LoadingWidget();

          if (state.categoryBreakdown.isEmpty && state.totalIncome == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(AppImages.empty, width: 150, height: 150),
                  const SizedBox(height: 16),
                  const Text('Chưa có dữ liệu thống kê',
                      style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: SummaryCard(title: 'Thu nhập', amount: state.totalIncome, icon: AppIcons.income, color: AppColors.income)),
                    const SizedBox(width: 12),
                    Expanded(child: SummaryCard(title: 'Chi tiêu', amount: state.totalExpense, icon: AppIcons.expense, color: AppColors.expense)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      const Text('Số dư hiện tại', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(AppDateUtils.formatCurrency(state.balance),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Chi tiêu theo danh mục',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (state.categoryBreakdown.isEmpty)
                  const Padding(padding: EdgeInsets.all(16), child: Center(child: Text('Chưa có chi tiêu')))
                else
                  ...state.categoryBreakdown.map((data) =>
                      CategoryBar(category: data.category, amount: data.amount, percentage: data.percentage)),
              ],
            ),
          );
        },
      ),
    );
  }
}
