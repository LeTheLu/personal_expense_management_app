import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:du_an/core/database/hive_boxes.dart';

class Budget extends Equatable {
  final String id;
  final String name;
  final double limitAmount;
  final double spentAmount;
  final int month;
  final int year;
  final int iconCodePoint;
  final String? preferredIncomeSourceId;
  final List<String> keywords;

  const Budget({
    required this.id,
    required this.name,
    required this.limitAmount,
    this.spentAmount = 0,
    required this.month,
    required this.year,
    this.iconCodePoint = 0xe25a,
    this.preferredIncomeSourceId,
    this.keywords = const [],
  });

  double get remainingAmount => limitAmount - spentAmount;
  double get progress => limitAmount > 0 ? (spentAmount / limitAmount).clamp(0.0, 1.0) : 0;
  bool get isOverBudget => spentAmount > limitAmount;
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  @override
  List<Object?> get props => [id, name, limitAmount, spentAmount, month, year, iconCodePoint, preferredIncomeSourceId, keywords];
}

class BudgetAdapter extends TypeAdapter<Budget> {
  @override
  final int typeId = HiveTypeIds.budget;

  @override
  Budget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Budget(
      id: fields[0] as String,
      name: fields[1] as String,
      limitAmount: fields[2] as double,
      spentAmount: fields[3] as double? ?? 0,
      month: fields[4] as int,
      year: fields[5] as int,
      iconCodePoint: fields[6] as int? ?? 0xe25a,
      preferredIncomeSourceId: fields[7] as String?,
      keywords: (fields[8] as List?)?.cast<String>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, Budget obj) {
    writer.writeByte(9);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.name);
    writer.writeByte(2); writer.write(obj.limitAmount);
    writer.writeByte(3); writer.write(obj.spentAmount);
    writer.writeByte(4); writer.write(obj.month);
    writer.writeByte(5); writer.write(obj.year);
    writer.writeByte(6); writer.write(obj.iconCodePoint);
    writer.writeByte(7); writer.write(obj.preferredIncomeSourceId);
    writer.writeByte(8); writer.write(obj.keywords);
  }
}
