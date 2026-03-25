import 'package:du_an/features/category/data/repositories/custom_category_repository.dart';
import 'package:du_an/features/budget/data/repositories/budget_repository.dart';

/// Validates keyword uniqueness across ALL entities (categories + budgets)
class KeywordValidator {
  final CustomCategoryRepository categoryRepo;
  final BudgetRepository budgetRepo;

  KeywordValidator({required this.categoryRepo, required this.budgetRepo});

  static String _normalize(String s) {
    const diacritics = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const plain = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    var result = s.toLowerCase().trim();
    for (int i = 0; i < diacritics.length; i++) {
      result = result.replaceAll(diacritics[i], plain[i]);
    }
    return result;
  }

  /// Check if keyword is already used in any category or budget
  bool isKeywordUsed(String keyword, {String? excludeCategoryId, String? excludeBudgetId}) {
    final normalized = _normalize(keyword);
    if (normalized.isEmpty) return false;

    // Check categories
    final usedInCategory = categoryRepo.getAll().any((c) =>
        c.id != excludeCategoryId &&
        c.keywords.any((k) => _normalize(k) == normalized));
    if (usedInCategory) return true;

    // Check budgets
    final usedInBudget = budgetRepo.getAll().any((b) =>
        b.id != excludeBudgetId &&
        b.keywords.any((k) => _normalize(k) == normalized));
    return usedInBudget;
  }

  /// Find which entity owns this keyword
  String? findOwner(String keyword) {
    final normalized = _normalize(keyword);
    for (final c in categoryRepo.getAll()) {
      if (c.keywords.any((k) => _normalize(k) == normalized)) return 'Danh mục "${c.name}"';
    }
    for (final b in budgetRepo.getAll()) {
      if (b.keywords.any((k) => _normalize(k) == normalized)) return 'Quỹ "${b.name}"';
    }
    return null;
  }
}
