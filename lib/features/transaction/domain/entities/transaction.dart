import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:du_an/core/database/hive_boxes.dart';

enum TransactionType { income, expense, transfer }

class TransactionEntity extends Equatable {
  final String id;
  final TransactionType type;
  final double amount;
  final String category;
  final String? subCategory;
  final String? from;
  final String? to;
  final DateTime date;
  final String? note;
  final String? budgetId;

  const TransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    this.subCategory,
    this.from,
    this.to,
    required this.date,
    this.note,
    this.budgetId,
  });

  @override
  List<Object?> get props => [id, type, amount, category, subCategory, from, to, date, note, budgetId];
}

// -- Hive Adapters --

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = HiveTypeIds.transactionType;

  @override
  TransactionType read(BinaryReader reader) => TransactionType.values[reader.readInt()];

  @override
  void write(BinaryWriter writer, TransactionType obj) => writer.writeInt(obj.index);
}

class TransactionEntityAdapter extends TypeAdapter<TransactionEntity> {
  @override
  final int typeId = HiveTypeIds.transaction;

  @override
  TransactionEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return TransactionEntity(
      id: fields[0] as String,
      type: fields[1] as TransactionType,
      amount: fields[2] as double,
      category: fields[3] as String,
      subCategory: fields[4] as String?,
      from: fields[5] as String?,
      to: fields[6] as String?,
      date: fields[7] as DateTime,
      note: fields[8] as String?,
      budgetId: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionEntity obj) {
    writer.writeByte(10);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.type);
    writer.writeByte(2); writer.write(obj.amount);
    writer.writeByte(3); writer.write(obj.category);
    writer.writeByte(4); writer.write(obj.subCategory);
    writer.writeByte(5); writer.write(obj.from);
    writer.writeByte(6); writer.write(obj.to);
    writer.writeByte(7); writer.write(obj.date);
    writer.writeByte(8); writer.write(obj.note);
    writer.writeByte(9); writer.write(obj.budgetId);
  }
}
