import 'package:hive/hive.dart';
import 'package:du_an/core/database/hive_boxes.dart';

class AppSettings {
  final String id;
  final List<String> addKeywords;
  final List<String> deductKeywords;
  final List<String> createKeywords; // chung: tạo, create, lập
  final List<String> budgetTypeKeywords; // quỹ, quỹ chi tiêu
  final List<String> savingTypeKeywords; // tích lũy, tiết kiệm
  final List<String> fixedExpenseTypeKeywords; // chi phí, chi phí cố định
  final List<String> incomeTypeKeywords; // thu nhập, nguồn thu, lương
  final int salaryDay;

  const AppSettings({
    this.id = 'app_settings',
    this.addKeywords = const ['them', 'cong', 'add', 'nap', 'tang'],
    this.deductKeywords = const ['chi', 'tru', 'tra', 'mua', 'spend'],
    this.createKeywords = const ['tao', 'create', 'lap', 'mo'],
    this.budgetTypeKeywords = const ['quy', 'quy chi tieu', 'budget'],
    this.savingTypeKeywords = const ['tich luy', 'tiet kiem', 'saving', 'muc tieu'],
    this.fixedExpenseTypeKeywords = const ['chi phi', 'chi phi co dinh', 'fixed'],
    this.incomeTypeKeywords = const ['thu nhap', 'nguon thu', 'luong', 'income'],
    this.salaryDay = 1,
  });
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = HiveTypeIds.appSettings;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return AppSettings(
      id: fields[0] as String? ?? 'app_settings',
      addKeywords: (fields[1] as List?)?.cast<String>() ?? const ['them', 'cong', 'add', 'nap', 'tang'],
      deductKeywords: (fields[2] as List?)?.cast<String>() ?? const ['chi', 'tru', 'tra', 'mua', 'spend'],
      salaryDay: fields[3] as int? ?? 1,
      createKeywords: (fields[4] as List?)?.cast<String>() ?? const ['tao', 'create', 'lap', 'mo'],
      budgetTypeKeywords: (fields[5] as List?)?.cast<String>() ?? const ['quy', 'quy chi tieu', 'budget'],
      savingTypeKeywords: (fields[6] as List?)?.cast<String>() ?? const ['tich luy', 'tiet kiem', 'saving', 'muc tieu'],
      fixedExpenseTypeKeywords: (fields[7] as List?)?.cast<String>() ?? const ['chi phi', 'chi phi co dinh', 'fixed'],
      incomeTypeKeywords: (fields[8] as List?)?.cast<String>() ?? const ['thu nhap', 'nguon thu', 'luong', 'income'],
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer.writeByte(9);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.addKeywords);
    writer.writeByte(2); writer.write(obj.deductKeywords);
    writer.writeByte(3); writer.write(obj.salaryDay);
    writer.writeByte(4); writer.write(obj.createKeywords);
    writer.writeByte(5); writer.write(obj.budgetTypeKeywords);
    writer.writeByte(6); writer.write(obj.savingTypeKeywords);
    writer.writeByte(7); writer.write(obj.fixedExpenseTypeKeywords);
    writer.writeByte(8); writer.write(obj.incomeTypeKeywords);
  }
}
