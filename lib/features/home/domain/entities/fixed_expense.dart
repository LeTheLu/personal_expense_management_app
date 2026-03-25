import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:du_an/core/database/hive_boxes.dart';

class FixedExpense extends Equatable {
  final String id;
  final String name;
  final double amount;
  final bool isPaid;
  final DateTime dueDate;
  final String? paidFrom;
  final int iconCodePoint;
  final bool isRecurring;
  final int dueDay; // ngày thanh toán hàng tháng (1-31)

  const FixedExpense({
    required this.id,
    required this.name,
    required this.amount,
    this.isPaid = false,
    required this.dueDate,
    this.paidFrom,
    this.iconCodePoint = 0xe54e,
    this.isRecurring = false,
    this.dueDay = 1,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  @override
  List<Object?> get props => [id, name, amount, isPaid, dueDate, paidFrom, iconCodePoint, isRecurring, dueDay];
}

class FixedExpenseAdapter extends TypeAdapter<FixedExpense> {
  @override
  final int typeId = HiveTypeIds.fixedExpense;

  @override
  FixedExpense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return FixedExpense(
      id: fields[0] as String,
      name: fields[1] as String,
      amount: fields[2] as double,
      isPaid: fields[3] as bool? ?? false,
      dueDate: fields[4] as DateTime,
      paidFrom: fields[5] as String?,
      iconCodePoint: fields[6] as int? ?? 0xe54e,
      isRecurring: fields[7] as bool? ?? false,
      dueDay: fields[8] as int? ?? 1,
    );
  }

  @override
  void write(BinaryWriter writer, FixedExpense obj) {
    writer.writeByte(9);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.name);
    writer.writeByte(2); writer.write(obj.amount);
    writer.writeByte(3); writer.write(obj.isPaid);
    writer.writeByte(4); writer.write(obj.dueDate);
    writer.writeByte(5); writer.write(obj.paidFrom);
    writer.writeByte(6); writer.write(obj.iconCodePoint);
    writer.writeByte(7); writer.write(obj.isRecurring);
    writer.writeByte(8); writer.write(obj.dueDay);
  }
}
