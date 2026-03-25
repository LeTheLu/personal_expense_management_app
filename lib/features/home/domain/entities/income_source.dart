import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:du_an/core/database/hive_boxes.dart';

class IncomeSource extends Equatable {
  final String id;
  final String name;
  final double amount;
  final double spentAmount;
  final DateTime date;
  final int iconCodePoint;

  const IncomeSource({
    required this.id,
    required this.name,
    required this.amount,
    this.spentAmount = 0,
    required this.date,
    this.iconCodePoint = 0xe559,
  });

  double get remainingAmount => amount - spentAmount;
  double get progress => amount > 0 ? (spentAmount / amount).clamp(0.0, 1.0) : 0;
  bool get isOverSpent => spentAmount > amount;
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  @override
  List<Object?> get props => [id, name, amount, spentAmount, date, iconCodePoint];
}

class IncomeSourceAdapter extends TypeAdapter<IncomeSource> {
  @override
  final int typeId = HiveTypeIds.incomeSource;

  @override
  IncomeSource read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return IncomeSource(
      id: fields[0] as String,
      name: fields[1] as String,
      amount: fields[2] as double,
      date: fields[3] as DateTime,
      iconCodePoint: fields[4] as int? ?? 0xe559,
      spentAmount: fields[5] as double? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, IncomeSource obj) {
    writer.writeByte(6);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.name);
    writer.writeByte(2); writer.write(obj.amount);
    writer.writeByte(3); writer.write(obj.date);
    writer.writeByte(4); writer.write(obj.iconCodePoint);
    writer.writeByte(5); writer.write(obj.spentAmount);
  }
}
