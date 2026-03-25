import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:du_an/core/services/keyword_validator.dart';
import 'package:du_an/features/category/data/repositories/custom_category_repository.dart';
import 'package:du_an/features/budget/data/repositories/budget_repository.dart';
import 'package:du_an/features/settings/data/repositories/app_settings_repository.dart';
import 'package:du_an/features/settings/domain/entities/app_settings.dart';
import 'keyword_settings_state.dart';

class KeywordSettingsCubit extends Cubit<KeywordSettingsState> {
  final CustomCategoryRepository categoryRepo;
  final BudgetRepository budgetRepo;
  final AppSettingsRepository settingsRepo;
  final KeywordValidator keywordValidator;

  KeywordSettingsCubit({
    required this.categoryRepo,
    required this.budgetRepo,
    required this.settingsRepo,
    required this.keywordValidator,
  }) : super(const KeywordSettingsState());

  void load() {
    final categories = categoryRepo.getAll();
    final budgets = budgetRepo.getAll();
    final settings = settingsRepo.get();
    emit(state.copyWith(categories: categories, budgets: budgets, settings: settings));
  }

  // Category keywords
  Future<void> addKeywordToCategory(String categoryId, String keyword) async {
    if (keyword.trim().isEmpty) return;
    if (keywordValidator.isKeywordUsed(keyword, excludeCategoryId: categoryId)) {
      final owner = keywordValidator.findOwner(keyword);
      emit(state.copyWith(error: 'Từ khóa "$keyword" đã được sử dụng ở $owner'));
      return;
    }
    await categoryRepo.addKeyword(categoryId, keyword.trim());
    load();
  }

  Future<void> removeCategoryKeyword(String categoryId, String keyword) async {
    await categoryRepo.removeKeyword(categoryId, keyword);
    load();
  }

  // Budget keywords
  Future<void> addKeywordToBudget(String budgetId, String keyword) async {
    if (keyword.trim().isEmpty) return;
    if (keywordValidator.isKeywordUsed(keyword, excludeBudgetId: budgetId)) {
      final owner = keywordValidator.findOwner(keyword);
      emit(state.copyWith(error: 'Từ khóa "$keyword" đã được sử dụng ở $owner'));
      return;
    }
    await budgetRepo.addKeyword(budgetId, keyword.trim());
    load();
  }

  Future<void> removeBudgetKeyword(String budgetId, String keyword) async {
    await budgetRepo.removeKeyword(budgetId, keyword);
    load();
  }

  // Action keywords
  Future<void> addActionKeyword(String keyword, {required bool isAdd}) async {
    final settings = settingsRepo.get();
    if (isAdd) {
      await settingsRepo.updateAddKeywords([...settings.addKeywords, keyword.trim()]);
    } else {
      await settingsRepo.updateDeductKeywords([...settings.deductKeywords, keyword.trim()]);
    }
    load();
  }

  Future<void> removeActionKeyword(String keyword, {required bool isAdd}) async {
    final settings = settingsRepo.get();
    if (isAdd) {
      await settingsRepo.updateAddKeywords(settings.addKeywords.where((k) => k != keyword).toList());
    } else {
      await settingsRepo.updateDeductKeywords(settings.deductKeywords.where((k) => k != keyword).toList());
    }
    load();
  }

  // Create keywords (shared)
  Future<void> addCreateKeyword(String keyword) async {
    final s = settingsRepo.get();
    await settingsRepo.save(AppSettings(
      addKeywords: s.addKeywords, deductKeywords: s.deductKeywords, salaryDay: s.salaryDay,
      createKeywords: [...s.createKeywords, keyword.trim()],
      budgetTypeKeywords: s.budgetTypeKeywords, savingTypeKeywords: s.savingTypeKeywords,
      fixedExpenseTypeKeywords: s.fixedExpenseTypeKeywords, incomeTypeKeywords: s.incomeTypeKeywords,
    ));
    load();
  }

  Future<void> removeCreateKeyword(String keyword) async {
    final s = settingsRepo.get();
    await settingsRepo.save(AppSettings(
      addKeywords: s.addKeywords, deductKeywords: s.deductKeywords, salaryDay: s.salaryDay,
      createKeywords: s.createKeywords.where((k) => k != keyword).toList(),
      budgetTypeKeywords: s.budgetTypeKeywords, savingTypeKeywords: s.savingTypeKeywords,
      fixedExpenseTypeKeywords: s.fixedExpenseTypeKeywords, incomeTypeKeywords: s.incomeTypeKeywords,
    ));
    load();
  }

  // Fund type keywords
  Future<void> addTypeKeyword(String keyword, {required String type}) async {
    final s = settingsRepo.get();
    final updated = AppSettings(
      addKeywords: s.addKeywords, deductKeywords: s.deductKeywords, salaryDay: s.salaryDay,
      createKeywords: s.createKeywords,
      budgetTypeKeywords: type == 'budget' ? [...s.budgetTypeKeywords, keyword.trim()] : s.budgetTypeKeywords,
      savingTypeKeywords: type == 'saving' ? [...s.savingTypeKeywords, keyword.trim()] : s.savingTypeKeywords,
      fixedExpenseTypeKeywords: type == 'fixed' ? [...s.fixedExpenseTypeKeywords, keyword.trim()] : s.fixedExpenseTypeKeywords,
      incomeTypeKeywords: type == 'income' ? [...s.incomeTypeKeywords, keyword.trim()] : s.incomeTypeKeywords,
    );
    await settingsRepo.save(updated);
    load();
  }

  Future<void> removeTypeKeyword(String keyword, {required String type}) async {
    final s = settingsRepo.get();
    final updated = AppSettings(
      addKeywords: s.addKeywords, deductKeywords: s.deductKeywords, salaryDay: s.salaryDay,
      createKeywords: s.createKeywords,
      budgetTypeKeywords: type == 'budget' ? s.budgetTypeKeywords.where((k) => k != keyword).toList() : s.budgetTypeKeywords,
      savingTypeKeywords: type == 'saving' ? s.savingTypeKeywords.where((k) => k != keyword).toList() : s.savingTypeKeywords,
      fixedExpenseTypeKeywords: type == 'fixed' ? s.fixedExpenseTypeKeywords.where((k) => k != keyword).toList() : s.fixedExpenseTypeKeywords,
      incomeTypeKeywords: type == 'income' ? s.incomeTypeKeywords.where((k) => k != keyword).toList() : s.incomeTypeKeywords,
    );
    await settingsRepo.save(updated);
    load();
  }

  Future<void> updateSalaryDay(int day) async {
    await settingsRepo.updateSalaryDay(day);
    load();
  }

  void clearError() => emit(state.copyWith(error: null));
}
