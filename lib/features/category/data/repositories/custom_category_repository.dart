import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:du_an/core/database/hive_boxes.dart';
import 'package:du_an/features/category/domain/entities/custom_category.dart';

class CustomCategoryRepository {
  Box<CustomCategory> get _box => Hive.box<CustomCategory>(HiveBoxes.customCategories);

  List<CustomCategory> getAll() => _box.values.toList();

  List<CustomCategory> getDefaults() => _box.values.where((c) => c.isDefault).toList();

  List<CustomCategory> getCustom() => _box.values.where((c) => !c.isDefault).toList();

  CustomCategory? getById(String id) => _box.get(id);

  CustomCategory? getByName(String name) {
    final normalized = _normalize(name);
    try {
      return _box.values.firstWhere((c) => _normalize(c.name) == normalized);
    } catch (_) {
      return null;
    }
  }

  /// Find category by keyword (diacritic/case insensitive)
  CustomCategory? findByKeyword(String keyword) {
    if (keyword.trim().isEmpty) return null;
    final normalized = _normalize(keyword);
    // Exact match
    try {
      return _box.values.firstWhere(
        (c) => c.keywords.any((k) => _normalize(k) == normalized),
      );
    } catch (_) {}
    // Word-boundary match: input contains keyword as whole word (not substring)
    try {
      return _box.values.firstWhere(
        (c) => c.keywords.any((k) {
          final kNorm = _normalize(k);
          if (kNorm.length < 2) return false; // skip single-char keywords
          // Check if keyword appears as whole word in input
          return RegExp('\\b$kNorm\\b').hasMatch(normalized);
        }),
      );
    } catch (_) {
      return null;
    }
  }

  /// Check if keyword exists in any category
  bool isKeywordUsed(String keyword, {String? excludeCategoryId}) {
    final normalized = _normalize(keyword);
    return _box.values.any((c) =>
        c.id != excludeCategoryId &&
        c.keywords.any((k) => _normalize(k) == normalized));
  }

  Future<void> add(CustomCategory category) async {
    await _box.put(category.id, category);
  }

  Future<void> update(CustomCategory category) async {
    await _box.put(category.id, category);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> addKeyword(String categoryId, String keyword) async {
    final category = _box.get(categoryId);
    if (category != null && !isKeywordUsed(keyword, excludeCategoryId: categoryId)) {
      final updated = CustomCategory(
        id: category.id,
        name: category.name,
        iconCodePoint: category.iconCodePoint,
        keywords: [...category.keywords, keyword],
        isDefault: category.isDefault,
      );
      await _box.put(categoryId, updated);
    }
  }

  Future<void> removeKeyword(String categoryId, String keyword) async {
    final category = _box.get(categoryId);
    if (category != null) {
      final updated = CustomCategory(
        id: category.id,
        name: category.name,
        iconCodePoint: category.iconCodePoint,
        keywords: category.keywords.where((k) => k != keyword).toList(),
        isDefault: category.isDefault,
      );
      await _box.put(categoryId, updated);
    }
  }

  /// Seed 8 default categories on first launch
  Future<void> seedDefaults() async {
    if (_box.isNotEmpty) return; // Already seeded

    const defaults = <Map<String, dynamic>>[
      {
        'id': 'cat_an_uong',
        'name': 'Ăn uống',
        'icon': Icons.restaurant,
        'keywords': ['an', 'com', 'pho', 'bun', 'cafe', 'tra', 'nuoc', 'banh', 'sua', 'do an', 'an sang', 'an trua', 'an toi', 'coffee', 'tra sua', 'bia', 'nhau'],
      },
      {
        'id': 'cat_di_chuyen',
        'name': 'Di chuyển',
        'icon': Icons.directions_car,
        'keywords': ['xang', 'grab', 'taxi', 'xe', 'giu xe', 'gui xe', 'dau', 'bus', 'do xang'],
      },
      {
        'id': 'cat_mua_sam',
        'name': 'Mua sắm',
        'icon': Icons.shopping_bag,
        'keywords': ['mua', 'quan ao', 'giay', 'shopee', 'lazada', 'tiki', 'do dung'],
      },
      {
        'id': 'cat_giai_tri',
        'name': 'Giải trí',
        'icon': Icons.movie,
        'keywords': ['phim', 'game', 'nhac', 'karaoke', 'du lich', 'choi'],
      },
      {
        'id': 'cat_suc_khoe',
        'name': 'Sức khỏe',
        'icon': Icons.local_hospital,
        'keywords': ['thuoc', 'kham', 'benh vien', 'nha thuoc', 'bac si', 'gym'],
      },
      {
        'id': 'cat_hoc_tap',
        'name': 'Học tập',
        'icon': Icons.school,
        'keywords': ['sach', 'khoa hoc', 'hoc', 'thi', 'truong'],
      },
      {
        'id': 'cat_hoa_don',
        'name': 'Hóa đơn',
        'icon': Icons.receipt,
        'keywords': ['dien', 'nuoc', 'mang', 'internet', 'dien thoai', 'wifi'],
      },
      {
        'id': 'cat_khac',
        'name': 'Khác',
        'icon': Icons.more_horiz,
        'keywords': <String>[],
      },
    ];

    for (final d in defaults) {
      final icon = d['icon'] as IconData;
      await add(CustomCategory(
        id: d['id'] as String,
        name: d['name'] as String,
        iconCodePoint: icon.codePoint,
        keywords: (d['keywords'] as List).cast<String>(),
        isDefault: true,
      ));
    }
  }

  static String _normalize(String s) {
    const diacritics = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const plain = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    var result = s.toLowerCase().trim();
    for (int i = 0; i < diacritics.length; i++) {
      result = result.replaceAll(diacritics[i], plain[i]);
    }
    return result;
  }
}
