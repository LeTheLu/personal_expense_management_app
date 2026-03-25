import 'package:hive/hive.dart';
import 'package:du_an/core/database/hive_boxes.dart';

class SavingHistoryEntry {
  final String id;
  final String savingId;
  final String action; // created, updated, addedAmount, deleted
  final String description;
  final double? oldAmount;
  final double? newAmount;
  final DateTime date;

  const SavingHistoryEntry({
    required this.id,
    required this.savingId,
    required this.action,
    required this.description,
    this.oldAmount,
    this.newAmount,
    required this.date,
  });
}

class SavingHistoryEntryAdapter extends TypeAdapter<SavingHistoryEntry> {
  @override
  final int typeId = HiveTypeIds.savingHistoryEntry;

  @override
  SavingHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return SavingHistoryEntry(
      id: fields[0] as String,
      savingId: fields[1] as String,
      action: fields[2] as String,
      description: fields[3] as String,
      oldAmount: fields[4] as double?,
      newAmount: fields[5] as double?,
      date: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavingHistoryEntry obj) {
    writer.writeByte(7);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.savingId);
    writer.writeByte(2); writer.write(obj.action);
    writer.writeByte(3); writer.write(obj.description);
    writer.writeByte(4); writer.write(obj.oldAmount);
    writer.writeByte(5); writer.write(obj.newAmount);
    writer.writeByte(6); writer.write(obj.date);
  }
}
