import 'package:hive/hive.dart';
import 'package:du_an/core/database/hive_boxes.dart';

class NotePattern {
  final String id;
  final String abbreviation;
  final String expansion;
  final int confirmCount;

  const NotePattern({
    required this.id,
    required this.abbreviation,
    required this.expansion,
    this.confirmCount = 0,
  });

  bool get isLearned => confirmCount >= 3;
}

class NotePatternAdapter extends TypeAdapter<NotePattern> {
  @override
  final int typeId = HiveTypeIds.notePattern;

  @override
  NotePattern read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return NotePattern(
      id: fields[0] as String,
      abbreviation: fields[1] as String,
      expansion: fields[2] as String,
      confirmCount: fields[3] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, NotePattern obj) {
    writer.writeByte(4);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.abbreviation);
    writer.writeByte(2); writer.write(obj.expansion);
    writer.writeByte(3); writer.write(obj.confirmCount);
  }
}
