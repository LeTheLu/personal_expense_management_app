import 'package:hive/hive.dart';
import 'package:du_an/core/database/hive_boxes.dart';
import 'package:du_an/features/transaction/domain/entities/transaction.dart';

class TransactionRepository {
  Box<TransactionEntity> get _box => Hive.box<TransactionEntity>(HiveBoxes.transactions);

  List<TransactionEntity> getAll() => _box.values.toList();

  List<TransactionEntity> getByMonth(int month, int year) {
    return _box.values.where((t) => t.date.month == month && t.date.year == year).toList();
  }

  List<TransactionEntity> getRecent({int limit = 5}) {
    final all = _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    return all.take(limit).toList();
  }

  List<TransactionEntity> getByCategory(String category) {
    return _box.values.where((t) => t.category == category).toList();
  }

  List<TransactionEntity> getByBudgetId(String budgetId) {
    return _box.values.where((t) => t.budgetId == budgetId).toList();
  }

  Future<void> add(TransactionEntity transaction) async {
    await _box.put(transaction.id, transaction);
  }

  Future<void> update(TransactionEntity transaction) async {
    await _box.put(transaction.id, transaction);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  double getTotalIncome(int month, int year) {
    return getByMonth(month, year)
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalExpense(int month, int year) {
    return getByMonth(month, year)
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> getCategoryBreakdown(int month, int year) {
    final expenses = getByMonth(month, year).where((t) => t.type == TransactionType.expense);
    final map = <String, double>{};
    for (final t in expenses) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  /// Get frequent transactions for suggestion engine
  List<Map<String, dynamic>> getFrequentPatterns() {
    final all = _box.values.toList();
    final patterns = <String, Map<String, dynamic>>{};

    for (final t in all) {
      final key = '${t.category}_${t.amount.round()}';
      if (patterns.containsKey(key)) {
        patterns[key]!['count'] = (patterns[key]!['count'] as int) + 1;
        patterns[key]!['lastDate'] = t.date;
      } else {
        patterns[key] = {
          'category': t.category,
          'amount': t.amount,
          'type': t.type,
          'count': 1,
          'lastDate': t.date,
          'hour': t.date.hour,
        };
      }
    }

    final sorted = patterns.values.toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    return sorted.take(20).toList();
  }
}
