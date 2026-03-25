import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/constants/app_icons.dart';
import 'package:du_an/di/injection.dart';
import 'package:du_an/router/app_router.dart';
import 'package:du_an/features/transaction/data/repositories/transaction_repository.dart';
import 'package:du_an/features/home/data/repositories/income_source_repository.dart';
import 'package:du_an/features/home/data/repositories/fixed_expense_repository.dart';
import 'package:du_an/features/budget/data/repositories/budget_repository.dart';
import 'package:du_an/features/saving/data/repositories/saving_repository.dart';
import 'package:du_an/features/settings/data/repositories/app_settings_repository.dart';
import 'package:du_an/features/home/presentation/cubit/home_cubit.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(AppRouter.statistics)) return 1;
    if (location.startsWith(AppRouter.settings)) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return BlocProvider(
      create: (_) => HomeCubit(
        transactionRepo: getIt<TransactionRepository>(),
        incomeSourceRepo: getIt<IncomeSourceRepository>(),
        fixedExpenseRepo: getIt<FixedExpenseRepository>(),
        budgetRepo: getIt<BudgetRepository>(),
        savingRepo: getIt<SavingRepository>(),
        settingsRepo: getIt<AppSettingsRepository>(),
      )..load(),
      child: Scaffold(
        body: child,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await context.push<bool>(AppRouter.addTransaction);
            if (result == true && context.mounted) {
              context.read<HomeCubit>().load();
            }
          },
          child: const Icon(Icons.add, size: 28),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: AppIcons.home,
                label: 'Trang chủ',
                index: 0,
                currentIndex: currentIndex,
                onTap: () => context.go(AppRouter.home),
              ),
              _buildNavItem(
                context: context,
                icon: AppIcons.stats,
                label: 'Thống kê',
                index: 1,
                currentIndex: currentIndex,
                onTap: () => context.go(AppRouter.statistics),
              ),
              const SizedBox(width: 48),
              _buildNavItem(
                context: context,
                icon: AppIcons.wallet,
                label: 'Ví tiền',
                index: -1,
                currentIndex: currentIndex,
                onTap: () {},
              ),
              _buildNavItem(
                context: context,
                icon: AppIcons.settings,
                label: 'Cài đặt',
                index: 2,
                currentIndex: currentIndex,
                onTap: () => context.go(AppRouter.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String icon,
    required String label,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isSelected = index == currentIndex;
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(icon, width: 20, height: 20, colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            )),
          ],
        ),
      ),
    );
  }
}
