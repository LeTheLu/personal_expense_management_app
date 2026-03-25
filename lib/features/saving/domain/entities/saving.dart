import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:du_an/core/database/hive_boxes.dart';

class Saving extends Equatable {
  final String id;
  final String name;
  final double currentAmount;
  final double targetAmount;
  final DateTime createdAt;
  final int iconCodePoint;

  const Saving({
    required this.id,
    required this.name,
    this.currentAmount = 0,
    required this.targetAmount,
    required this.createdAt,
    this.iconCodePoint = 0xe57c, // savings
  });

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0;
  double get remainingAmount => targetAmount - currentAmount;
  bool get isCompleted => currentAmount >= targetAmount;
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  @override
  List<Object?> get props => [id, name, currentAmount, targetAmount, createdAt, iconCodePoint];
}

class SavingAdapter extends TypeAdapter<Saving> {
  @override
  final int typeId = HiveTypeIds.saving;

  @override
  Saving read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Saving(
      id: fields[0] as String,
      name: fields[1] as String,
      currentAmount: fields[2] as double? ?? 0,
      targetAmount: fields[3] as double,
      createdAt: fields[4] as DateTime,
      iconCodePoint: fields[5] as int? ?? 0xe57c,
    );
  }

  @override
  void write(BinaryWriter writer, Saving obj) {
    writer.writeByte(6);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.name);
    writer.writeByte(2); writer.write(obj.currentAmount);
    writer.writeByte(3); writer.write(obj.targetAmount);
    writer.writeByte(4); writer.write(obj.createdAt);
    writer.writeByte(5); writer.write(obj.iconCodePoint);
  }
}
