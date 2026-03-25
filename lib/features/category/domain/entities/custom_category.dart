import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:du_an/core/database/hive_boxes.dart';

class CustomCategory extends Equatable {
  final String id;
  final String name;
  final int iconCodePoint;
  final List<String> keywords;
  final bool isDefault;

  const CustomCategory({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    this.keywords = const [],
    this.isDefault = false,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  @override
  List<Object?> get props => [id, name, iconCodePoint, keywords, isDefault];
}

class CustomCategoryAdapter extends TypeAdapter<CustomCategory> {
  @override
  final int typeId = HiveTypeIds.customCategory;

  @override
  CustomCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return CustomCategory(
      id: fields[0] as String,
      name: fields[1] as String,
      iconCodePoint: fields[2] as int,
      keywords: (fields[3] as List?)?.cast<String>() ?? [],
      isDefault: fields[4] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, CustomCategory obj) {
    writer.writeByte(5);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.name);
    writer.writeByte(2); writer.write(obj.iconCodePoint);
    writer.writeByte(3); writer.write(obj.keywords);
    writer.writeByte(4); writer.write(obj.isDefault);
  }
}
