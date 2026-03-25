import 'package:hive/hive.dart';
import 'package:du_an/core/database/hive_boxes.dart';
import 'package:du_an/features/home/domain/entities/fixed_expense.dart';

class FixedExpenseRepository {
  Box<FixedExpense> get _box => Hive.box<FixedExpense>(HiveBoxes.fixedExpenses);

  List<FixedExpense> getAll() => _box.values.toList();

  List<FixedExpense> getByMonth(int month, int year) {
    return _box.values.where((f) => f.dueDate.month == month && f.dueDate.year == year).toList();
  }

  Future<void> add(FixedExpense item) async {
    await _box.put(item.id, item);
  }

  Future<void> update(FixedExpense item) async {
    await _box.put(item.id, item);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> togglePaid(String id, {String? paidFrom}) async {
    final item = _box.get(id);
    if (item != null) {
      final updated = FixedExpense(
        id: item.id,
        name: item.name,
        amount: item.amount,
        isPaid: !item.isPaid,
        dueDate: item.dueDate,
        paidFrom: item.isPaid ? null : paidFrom,
        iconCodePoint: item.iconCodePoint,
      );
      await _box.put(id, updated);
    }
  }
}
