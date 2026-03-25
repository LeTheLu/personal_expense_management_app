import 'package:hive/hive.dart';
import 'package:du_an/core/database/hive_boxes.dart';
import 'package:du_an/features/budget/domain/entities/budget.dart';
import 'package:du_an/features/budget/domain/entities/budget_history.dart';

class BudgetRepository {
  Box<Budget> get _box => Hive.box<Budget>(HiveBoxes.budgets);
  Box<BudgetHistoryEntry> get _historyBox => Hive.box<BudgetHistoryEntry>(HiveBoxes.budgetHistory);

  List<Budget> getAll() => _box.values.toList();

  List<Budget> getByMonth(int month, int year) {
    return _box.values.where((b) => b.month == month && b.year == year).toList();
  }

  Budget? getById(String id) => _box.get(id);

  /// Find budget by name (for auto-matching transactions by category)
  /// Uses normalized comparison to handle diacritics/case differences
  Budget? findByName(String name, int month, int year) {
    final normalized = _normalize(name);
    try {
      return _box.values.firstWhere(
        (b) => _normalize(b.name) == normalized && b.month == month && b.year == year,
      );
    } catch (_) {
      return null;
    }
  }

  static String _normalize(String s) {
    const diacritics = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const plain      = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    var result = s.toLowerCase().trim();
    for (int i = 0; i < diacritics.length; i++) {
      result = result.replaceAll(diacritics[i], plain[i]);
    }
    return result;
  }

  Future<void> add(Budget budget) async {
    await _box.put(budget.id, budget);
    _addHistory(
      budgetId: budget.id,
      action: 'created',
      description: 'Tao quy "${budget.name}" han muc ${budget.limitAmount}',
      newAmount: budget.limitAmount,
    );
  }

  Future<void> update(Budget budget) async {
    final old = _box.get(budget.id);
    await _box.put(budget.id, budget);

    final changes = <String>[];
    if (old != null && old.name != budget.name) changes.add('Ten: "${old.name}" -> "${budget.name}"');
    if (old != null && old.limitAmount != budget.limitAmount) changes.add('Han muc: ${old.limitAmount} -> ${budget.limitAmount}');

    _addHistory(
      budgetId: budget.id,
      action: 'updated',
      description: changes.isNotEmpty ? changes.join(', ') : 'Cap nhat thong tin',
      oldAmount: old?.limitAmount,
      newAmount: budget.limitAmount,
    );
  }

  Future<void> delete(String id) async {
    final old = _box.get(id);
    await _box.delete(id);
    if (old != null) {
      _addHistory(
        budgetId: id,
        action: 'deleted',
        description: 'Xoa quy "${old.name}" (${old.spentAmount}/${old.limitAmount})',
        oldAmount: old.spentAmount,
      );
    }
  }

  Future<void> updateSpent(String id, double newSpent, {String? note}) async {
    final budget = _box.get(id);
    if (budget != null) {
      final oldSpent = budget.spentAmount;
      final updated = Budget(
        id: budget.id,
        name: budget.name,
        limitAmount: budget.limitAmount,
        spentAmount: newSpent,
        month: budget.month,
        year: budget.year,
        iconCodePoint: budget.iconCodePoint,
        preferredIncomeSourceId: budget.preferredIncomeSourceId,
      );
      await _box.put(id, updated);

      final diff = newSpent - oldSpent;
      final desc = note ?? 'Chi tieu ${diff > 0 ? '+' : ''}$diff ($oldSpent -> $newSpent)';

      _addHistory(
        budgetId: id,
        action: 'spent',
        description: desc,
        oldAmount: oldSpent,
        newAmount: newSpent,
      );
    }
  }

  /// Find budget by keyword
  Budget? findByKeyword(String keyword, int month, int year) {
    final normalized = _normalize(keyword);
    try {
      return _box.values.firstWhere(
        (b) => b.month == month && b.year == year &&
            b.keywords.any((k) => _normalize(k) == normalized || normalized.contains(_normalize(k)) || _normalize(k).contains(normalized)),
      );
    } catch (_) {
      return null;
    }
  }

  /// Check if keyword is used in any budget
  bool isKeywordUsed(String keyword, {String? excludeBudgetId}) {
    final normalized = _normalize(keyword);
    return _box.values.any((b) =>
        b.id != excludeBudgetId &&
        b.keywords.any((k) => _normalize(k) == normalized));
  }

  Future<void> addKeyword(String budgetId, String keyword) async {
    final budget = _box.get(budgetId);
    if (budget != null) {
      final updated = Budget(
        id: budget.id, name: budget.name, limitAmount: budget.limitAmount,
        spentAmount: budget.spentAmount, month: budget.month, year: budget.year,
        iconCodePoint: budget.iconCodePoint, preferredIncomeSourceId: budget.preferredIncomeSourceId,
        keywords: [...budget.keywords, keyword],
      );
      await _box.put(budgetId, updated);
    }
  }

  Future<void> removeKeyword(String budgetId, String keyword) async {
    final budget = _box.get(budgetId);
    if (budget != null) {
      final updated = Budget(
        id: budget.id, name: budget.name, limitAmount: budget.limitAmount,
        spentAmount: budget.spentAmount, month: budget.month, year: budget.year,
        iconCodePoint: budget.iconCodePoint, preferredIncomeSourceId: budget.preferredIncomeSourceId,
        keywords: budget.keywords.where((k) => k != keyword).toList(),
      );
      await _box.put(budgetId, updated);
    }
  }

  List<BudgetHistoryEntry> getHistory(String budgetId) {
    return _historyBox.values
        .where((h) => h.budgetId == budgetId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void _addHistory({
    required String budgetId,
    required String action,
    required String description,
    double? oldAmount,
    double? newAmount,
  }) {
    final entry = BudgetHistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      budgetId: budgetId,
      action: action,
      description: description,
      oldAmount: oldAmount,
      newAmount: newAmount,
      date: DateTime.now(),
    );
    _historyBox.put(entry.id, entry);
  }
}
