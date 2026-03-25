import 'package:hive/hive.dart';
import 'package:du_an/core/database/hive_boxes.dart';

enum IncomeHistoryAction { created, updated, addedAmount, deleted }

class IncomeHistoryEntry {
  final String id;
  final String incomeSourceId;
  final String action; // created, updated, addedAmount, deleted
  final String description;
  final double? oldAmount;
  final double? newAmount;
  final String? oldName;
  final String? newName;
  final DateTime date;

  const IncomeHistoryEntry({
    required this.id,
    required this.incomeSourceId,
    required this.action,
    required this.description,
    this.oldAmount,
    this.newAmount,
    this.oldName,
    this.newName,
    required this.date,
  });
}

class IncomeHistoryEntryAdapter extends TypeAdapter<IncomeHistoryEntry> {
  @override
  final int typeId = HiveTypeIds.incomeHistoryEntry;

  @override
  IncomeHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return IncomeHistoryEntry(
      id: fields[0] as String,
      incomeSourceId: fields[1] as String,
      action: fields[2] as String,
      description: fields[3] as String,
      oldAmount: fields[4] as double?,
      newAmount: fields[5] as double?,
      oldName: fields[6] as String?,
      newName: fields[7] as String?,
      date: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, IncomeHistoryEntry obj) {
    writer.writeByte(9);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.incomeSourceId);
    writer.writeByte(2); writer.write(obj.action);
    writer.writeByte(3); writer.write(obj.description);
    writer.writeByte(4); writer.write(obj.oldAmount);
    writer.writeByte(5); writer.write(obj.newAmount);
    writer.writeByte(6); writer.write(obj.oldName);
    writer.writeByte(7); writer.write(obj.newName);
    writer.writeByte(8); writer.write(obj.date);
  }
}
