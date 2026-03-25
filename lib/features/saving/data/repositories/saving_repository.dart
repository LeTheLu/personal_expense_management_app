import 'package:hive/hive.dart';
import 'package:du_an/core/database/hive_boxes.dart';
import 'package:du_an/features/saving/domain/entities/saving.dart';
import 'package:du_an/features/saving/domain/entities/saving_history.dart';

class SavingRepository {
  Box<Saving> get _box => Hive.box<Saving>(HiveBoxes.savings);
  Box<SavingHistoryEntry> get _historyBox => Hive.box<SavingHistoryEntry>(HiveBoxes.savingHistory);

  List<Saving> getAll() => _box.values.toList();

  Saving? getById(String id) => _box.get(id);

  double getTotalSaved() {
    return _box.values.fold(0.0, (sum, s) => sum + s.currentAmount);
  }

  Future<void> add(Saving saving) async {
    await _box.put(saving.id, saving);
    _addHistory(
      savingId: saving.id,
      action: 'created',
      description: 'Tạo mục tiêu "${saving.name}" - ${saving.targetAmount}',
      newAmount: saving.currentAmount,
    );
  }

  Future<void> update(Saving saving) async {
    final old = _box.get(saving.id);
    await _box.put(saving.id, saving);

    final changes = <String>[];
    if (old != null && old.name != saving.name) {
      changes.add('Ten: "${old.name}" -> "${saving.name}"');
    }
    if (old != null && old.targetAmount != saving.targetAmount) {
      changes.add('Muc tieu: ${old.targetAmount} -> ${saving.targetAmount}');
    }
    if (old != null && old.currentAmount != saving.currentAmount) {
      changes.add('So tien: ${old.currentAmount} -> ${saving.currentAmount}');
    }

    _addHistory(
      savingId: saving.id,
      action: 'updated',
      description: changes.isNotEmpty ? changes.join(', ') : 'Cap nhat thong tin',
      oldAmount: old?.currentAmount,
      newAmount: saving.currentAmount,
    );
  }

  Future<void> delete(String id) async {
    final old = _box.get(id);
    await _box.delete(id);
    if (old != null) {
      _addHistory(
        savingId: id,
        action: 'deleted',
        description: 'Xoa muc tieu "${old.name}" (${old.currentAmount}/${old.targetAmount})',
        oldAmount: old.currentAmount,
      );
    }
  }

  Future<void> addAmount(String id, double amount) async {
    final saving = _box.get(id);
    if (saving != null) {
      final oldAmount = saving.currentAmount;
      final updated = Saving(
        id: saving.id,
        name: saving.name,
        currentAmount: saving.currentAmount + amount,
        targetAmount: saving.targetAmount,
        createdAt: saving.createdAt,
        iconCodePoint: saving.iconCodePoint,
      );
      await _box.put(id, updated);
      _addHistory(
        savingId: id,
        action: 'addedAmount',
        description: 'Them +${amount} vao "${saving.name}" ($oldAmount -> ${updated.currentAmount})',
        oldAmount: oldAmount,
        newAmount: updated.currentAmount,
      );
    }
  }

  List<SavingHistoryEntry> getHistory(String savingId) {
    return _historyBox.values
        .where((h) => h.savingId == savingId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void _addHistory({
    required String savingId,
    required String action,
    required String description,
    double? oldAmount,
    double? newAmount,
  }) {
    final entry = SavingHistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      savingId: savingId,
      action: action,
      description: description,
      oldAmount: oldAmount,
      newAmount: newAmount,
      date: DateTime.now(),
    );
    _historyBox.put(entry.id, entry);
  }
}
