import 'package:hive/hive.dart';
import 'package:du_an/core/database/hive_boxes.dart';
import 'package:du_an/features/settings/domain/entities/app_settings.dart';

class AppSettingsRepository {
  Box<AppSettings> get _box => Hive.box<AppSettings>(HiveBoxes.appSettings);

  AppSettings get() {
    return _box.get('app_settings') ?? const AppSettings();
  }

  Future<void> save(AppSettings settings) async {
    await _box.put('app_settings', settings);
  }

  Future<void> updateSalaryDay(int day) async {
    final c = get();
    await save(AppSettings(
      addKeywords: c.addKeywords, deductKeywords: c.deductKeywords, salaryDay: day,
      createKeywords: c.createKeywords, budgetTypeKeywords: c.budgetTypeKeywords,
      savingTypeKeywords: c.savingTypeKeywords, fixedExpenseTypeKeywords: c.fixedExpenseTypeKeywords,
      incomeTypeKeywords: c.incomeTypeKeywords,
    ));
  }

  Future<void> updateAddKeywords(List<String> keywords) async {
    final c = get();
    await save(AppSettings(
      addKeywords: keywords, deductKeywords: c.deductKeywords, salaryDay: c.salaryDay,
      createKeywords: c.createKeywords, budgetTypeKeywords: c.budgetTypeKeywords,
      savingTypeKeywords: c.savingTypeKeywords, fixedExpenseTypeKeywords: c.fixedExpenseTypeKeywords,
      incomeTypeKeywords: c.incomeTypeKeywords,
    ));
  }

  Future<void> updateDeductKeywords(List<String> keywords) async {
    final c = get();
    await save(AppSettings(
      addKeywords: c.addKeywords, deductKeywords: keywords, salaryDay: c.salaryDay,
      createKeywords: c.createKeywords, budgetTypeKeywords: c.budgetTypeKeywords,
      savingTypeKeywords: c.savingTypeKeywords, fixedExpenseTypeKeywords: c.fixedExpenseTypeKeywords,
      incomeTypeKeywords: c.incomeTypeKeywords,
    ));
  }
}
