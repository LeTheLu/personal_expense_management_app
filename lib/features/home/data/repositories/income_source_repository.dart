import 'package:hive/hive.dart';
import 'package:du_an/core/database/hive_boxes.dart';
import 'package:du_an/features/home/domain/entities/income_source.dart';
import 'package:du_an/features/home/domain/entities/income_history.dart';

class IncomeSourceRepository {
  Box<IncomeSource> get _box => Hive.box<IncomeSource>(HiveBoxes.incomeSources);
  Box<IncomeHistoryEntry> get _historyBox => Hive.box<IncomeHistoryEntry>(HiveBoxes.incomeHistory);

  List<IncomeSource> getAll() => _box.values.toList();

  IncomeSource? getById(String id) => _box.get(id);

  List<IncomeSource> getByMonth(int month, int year) {
    return _box.values.where((s) => s.date.month == month && s.date.year == year).toList();
  }

  double getTotalByMonth(int month, int year) {
    return getByMonth(month, year).fold(0.0, (sum, s) => sum + s.amount);
  }

  Future<void> add(IncomeSource source) async {
    await _box.put(source.id, source);
    _addHistory(
      incomeSourceId: source.id,
      action: 'created',
      description: 'Tao nguon thu "${source.name}" voi so tien ${source.amount}',
      newAmount: source.amount,
      newName: source.name,
    );
  }

  Future<void> update(IncomeSource source) async {
    final old = _box.get(source.id);
    await _box.put(source.id, source);

    final changes = <String>[];
    if (old != null && old.name != source.name) {
      changes.add('Ten: "${old.name}" -> "${source.name}"');
    }
    if (old != null && old.amount != source.amount) {
      changes.add('So tien: ${old.amount} -> ${source.amount}');
    }
    if (old != null && old.iconCodePoint != source.iconCodePoint) {
      changes.add('Doi icon');
    }

    _addHistory(
      incomeSourceId: source.id,
      action: 'updated',
      description: changes.isNotEmpty ? changes.join(', ') : 'Cap nhat thong tin',
      oldAmount: old?.amount,
      newAmount: source.amount,
      oldName: old?.name,
      newName: source.name,
    );
  }

  Future<void> delete(String id) async {
    final old = _box.get(id);
    await _box.delete(id);
    if (old != null) {
      _addHistory(
        incomeSourceId: id,
        action: 'deleted',
        description: 'Xoa nguon thu "${old.name}" (${old.amount})',
        oldAmount: old.amount,
        oldName: old.name,
      );
    }
  }

  Future<void> addAmount(String id, double amount) async {
    final source = _box.get(id);
    if (source != null) {
      final oldAmount = source.amount;
      final updated = IncomeSource(
        id: source.id,
        name: source.name,
        amount: source.amount + amount,
        spentAmount: source.spentAmount,
        date: source.date,
        iconCodePoint: source.iconCodePoint,
      );
      await _box.put(id, updated);
      _addHistory(
        incomeSourceId: id,
        action: 'addedAmount',
        description: 'Cộng dồn +$amount vào "${source.name}" ($oldAmount -> ${updated.amount})',
        oldAmount: oldAmount,
        newAmount: updated.amount,
      );
    }
  }

  /// Deduct amount from income source (for saving / fixed expense)
  Future<void> deductAmount(String id, double amount, {required String description}) async {
    final source = _box.get(id);
    if (source != null) {
      final oldSpent = source.spentAmount;
      final updated = IncomeSource(
        id: source.id,
        name: source.name,
        amount: source.amount,
        spentAmount: source.spentAmount + amount,
        date: source.date,
        iconCodePoint: source.iconCodePoint,
      );
      await _box.put(id, updated);
      _addHistory(
        incomeSourceId: id,
        action: 'deducted',
        description: description,
        oldAmount: oldSpent,
        newAmount: updated.spentAmount,
      );
    }
  }

  /// Refund amount back to income source (when unpaid fixed expense)
  Future<void> refundAmount(String id, double amount, {required String description}) async {
    final source = _box.get(id);
    if (source != null) {
      final oldSpent = source.spentAmount;
      final newSpent = (source.spentAmount - amount).clamp(0.0, double.infinity);
      final updated = IncomeSource(
        id: source.id,
        name: source.name,
        amount: source.amount,
        spentAmount: newSpent,
        date: source.date,
        iconCodePoint: source.iconCodePoint,
      );
      await _box.put(id, updated);
      _addHistory(
        incomeSourceId: id,
        action: 'refunded',
        description: description,
        oldAmount: oldSpent,
        newAmount: newSpent,
      );
    }
  }

  /// Get unique names for suggestions
  List<IncomeSource> getUniqueByName() {
    final seen = <String>{};
    final unique = <IncomeSource>[];
    for (final s in _box.values) {
      if (!seen.contains(s.name)) {
        seen.add(s.name);
        unique.add(s);
      }
    }
    return unique;
  }

  /// Get history for a specific income source
  List<IncomeHistoryEntry> getHistory(String incomeSourceId) {
    final entries = _historyBox.values
        .where((h) => h.incomeSourceId == incomeSourceId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  /// Get all history
  List<IncomeHistoryEntry> getAllHistory() {
    final entries = _historyBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  void _addHistory({
    required String incomeSourceId,
    required String action,
    required String description,
    double? oldAmount,
    double? newAmount,
    String? oldName,
    String? newName,
  }) {
    final entry = IncomeHistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      incomeSourceId: incomeSourceId,
      action: action,
      description: description,
      oldAmount: oldAmount,
      newAmount: newAmount,
      oldName: oldName,
      newName: newName,
      date: DateTime.now(),
    );
    _historyBox.put(entry.id, entry);
  }
}
