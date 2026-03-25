import 'package:hive/hive.dart';
import 'package:du_an/core/database/hive_boxes.dart';

class BudgetHistoryEntry {
  final String id;
  final String budgetId;
  final String action; // created, updated, spent, deleted
  final String description;
  final double? oldAmount;
  final double? newAmount;
  final DateTime date;

  const BudgetHistoryEntry({
    required this.id,
    required this.budgetId,
    required this.action,
    required this.description,
    this.oldAmount,
    this.newAmount,
    required this.date,
  });
}

class BudgetHistoryEntryAdapter extends TypeAdapter<BudgetHistoryEntry> {
  @override
  final int typeId = HiveTypeIds.budgetHistoryEntry;

  @override
  BudgetHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return BudgetHistoryEntry(
      id: fields[0] as String,
      budgetId: fields[1] as String,
      action: fields[2] as String,
      description: fields[3] as String,
      oldAmount: fields[4] as double?,
      newAmount: fields[5] as double?,
      date: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetHistoryEntry obj) {
    writer.writeByte(7);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.budgetId);
    writer.writeByte(2); writer.write(obj.action);
    writer.writeByte(3); writer.write(obj.description);
    writer.writeByte(4); writer.write(obj.oldAmount);
    writer.writeByte(5); writer.write(obj.newAmount);
    writer.writeByte(6); writer.write(obj.date);
  }
}
