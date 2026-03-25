import 'package:du_an/features/home/data/repositories/income_source_repository.dart';
import 'package:du_an/features/budget/data/repositories/budget_repository.dart';
import 'package:du_an/features/saving/data/repositories/saving_repository.dart';
import 'package:du_an/features/home/data/repositories/fixed_expense_repository.dart';
import 'package:du_an/features/category/data/repositories/custom_category_repository.dart';

class IconRegistry {
  final IncomeSourceRepository incomeSourceRepo;
  final BudgetRepository budgetRepo;
  final SavingRepository savingRepo;
  final FixedExpenseRepository fixedExpenseRepo;
  final CustomCategoryRepository categoryRepo;

  IconRegistry({
    required this.incomeSourceRepo,
    required this.budgetRepo,
    required this.savingRepo,
    required this.fixedExpenseRepo,
    required this.categoryRepo,
  });

  Set<int> getUsedIconCodePoints() {
    final used = <int>{};
    for (final s in incomeSourceRepo.getAll()) {
      used.add(s.iconCodePoint);
    }
    for (final b in budgetRepo.getAll()) {
      used.add(b.iconCodePoint);
    }
    for (final s in savingRepo.getAll()) {
      used.add(s.iconCodePoint);
    }
    for (final f in fixedExpenseRepo.getAll()) {
      used.add(f.iconCodePoint);
    }
    for (final c in categoryRepo.getAll()) {
      used.add(c.iconCodePoint);
    }
    return used;
  }

  bool isIconAvailable(int codePoint) => !getUsedIconCodePoints().contains(codePoint);
}
