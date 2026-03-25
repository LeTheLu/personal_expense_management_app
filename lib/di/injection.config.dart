// Manual DI configuration

import 'package:du_an/core/network/dio_client.dart';
import 'package:du_an/core/services/icon_registry.dart';
import 'package:du_an/features/transaction/data/repositories/transaction_repository.dart';
import 'package:du_an/features/home/data/repositories/income_source_repository.dart';
import 'package:du_an/features/budget/data/repositories/budget_repository.dart';
import 'package:du_an/features/saving/data/repositories/saving_repository.dart';
import 'package:du_an/features/home/data/repositories/fixed_expense_repository.dart';
import 'package:du_an/features/category/data/repositories/custom_category_repository.dart';
import 'package:du_an/features/settings/data/repositories/app_settings_repository.dart';
import 'package:du_an/core/services/keyword_validator.dart';
import 'package:du_an/features/suggestion/domain/suggestion_engine.dart';
import 'package:du_an/features/suggestion/data/repositories/note_pattern_repository.dart';
import 'package:get_it/get_it.dart';

extension GetItInjectableX on GetIt {
  GetIt init({
    String? environment,
  }) {
    // Core
    registerLazySingleton<DioClient>(() => DioClient());

    // Repositories (Hive-based)
    registerLazySingleton<TransactionRepository>(() => TransactionRepository());
    registerLazySingleton<IncomeSourceRepository>(() => IncomeSourceRepository());
    registerLazySingleton<BudgetRepository>(() => BudgetRepository());
    registerLazySingleton<SavingRepository>(() => SavingRepository());
    registerLazySingleton<FixedExpenseRepository>(() => FixedExpenseRepository());
    registerLazySingleton<CustomCategoryRepository>(() => CustomCategoryRepository());
    registerLazySingleton<AppSettingsRepository>(() => AppSettingsRepository());

    // Services
    registerLazySingleton<IconRegistry>(() => IconRegistry(
          incomeSourceRepo: get<IncomeSourceRepository>(),
          budgetRepo: get<BudgetRepository>(),
          savingRepo: get<SavingRepository>(),
          fixedExpenseRepo: get<FixedExpenseRepository>(),
          categoryRepo: get<CustomCategoryRepository>(),
        ));

    registerLazySingleton<NotePatternRepository>(() => NotePatternRepository());
    registerLazySingleton<KeywordValidator>(() => KeywordValidator(
          categoryRepo: get<CustomCategoryRepository>(),
          budgetRepo: get<BudgetRepository>(),
        ));

    // Suggestion Engine
    registerLazySingleton<SuggestionEngine>(
      () => SuggestionEngine(transactionRepository: get<TransactionRepository>()),
    );

    return this;
  }
}
