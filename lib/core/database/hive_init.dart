import 'package:hive_flutter/hive_flutter.dart';
import 'package:du_an/core/database/hive_boxes.dart';
import 'package:du_an/features/transaction/domain/entities/transaction.dart';
import 'package:du_an/features/home/domain/entities/income_source.dart';
import 'package:du_an/features/home/domain/entities/income_history.dart';
import 'package:du_an/features/budget/domain/entities/budget.dart';
import 'package:du_an/features/budget/domain/entities/budget_history.dart';
import 'package:du_an/features/saving/domain/entities/saving.dart';
import 'package:du_an/features/saving/domain/entities/saving_history.dart';
import 'package:du_an/features/home/domain/entities/fixed_expense.dart';
import 'package:du_an/features/category/domain/entities/custom_category.dart';
import 'package:du_an/features/suggestion/domain/entities/note_pattern.dart';
import 'package:du_an/features/settings/domain/entities/app_settings.dart';

Future<void> initHive() async {
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionEntityAdapter());
  Hive.registerAdapter(IncomeSourceAdapter());
  Hive.registerAdapter(IncomeHistoryEntryAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(BudgetHistoryEntryAdapter());
  Hive.registerAdapter(SavingAdapter());
  Hive.registerAdapter(SavingHistoryEntryAdapter());
  Hive.registerAdapter(FixedExpenseAdapter());
  Hive.registerAdapter(CustomCategoryAdapter());
  Hive.registerAdapter(NotePatternAdapter());
  Hive.registerAdapter(AppSettingsAdapter());

  // Open boxes
  await Future.wait([
    Hive.openBox<TransactionEntity>(HiveBoxes.transactions),
    Hive.openBox<IncomeSource>(HiveBoxes.incomeSources),
    Hive.openBox<IncomeHistoryEntry>(HiveBoxes.incomeHistory),
    Hive.openBox<Budget>(HiveBoxes.budgets),
    Hive.openBox<BudgetHistoryEntry>(HiveBoxes.budgetHistory),
    Hive.openBox<Saving>(HiveBoxes.savings),
    Hive.openBox<SavingHistoryEntry>(HiveBoxes.savingHistory),
    Hive.openBox<FixedExpense>(HiveBoxes.fixedExpenses),
    Hive.openBox<CustomCategory>(HiveBoxes.customCategories),
    Hive.openBox<NotePattern>(HiveBoxes.notePatterns),
    Hive.openBox<AppSettings>(HiveBoxes.appSettings),
    Hive.openBox(HiveBoxes.wallet),
    Hive.openBox(HiveBoxes.suggestions),
  ]);
}
