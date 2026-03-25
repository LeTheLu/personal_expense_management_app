import 'package:hive/hive.dart';
import 'package:du_an/core/database/hive_boxes.dart';
import 'package:du_an/features/suggestion/domain/entities/note_pattern.dart';

class NotePatternRepository {
  Box<NotePattern> get _box => Hive.box<NotePattern>(HiveBoxes.notePatterns);

  List<String> getSuggestionsForInput(String input) {
    if (input.isEmpty) return [];
    final lower = input.toLowerCase();
    final results = <String>[];

    // Learned patterns (confirmed >= 3 times)
    for (final p in _box.values) {
      if (p.isLearned && p.abbreviation.toLowerCase().startsWith(lower)) {
        results.add(p.expansion);
      }
    }

    // All previous expansions that start with input
    for (final p in _box.values) {
      if (p.expansion.toLowerCase().startsWith(lower) && !results.contains(p.expansion)) {
        results.add(p.expansion);
      }
    }

    return results.take(5).toList();
  }

  Future<void> recordConfirmation(String abbreviation, String expansion) async {
    final key = '${abbreviation.toLowerCase()}_${expansion.toLowerCase()}';
    final existing = _box.get(key);
    if (existing != null) {
      final updated = NotePattern(
        id: existing.id,
        abbreviation: existing.abbreviation,
        expansion: existing.expansion,
        confirmCount: existing.confirmCount + 1,
      );
      await _box.put(key, updated);
    } else {
      final pattern = NotePattern(
        id: key,
        abbreviation: abbreviation,
        expansion: expansion,
        confirmCount: 1,
      );
      await _box.put(key, pattern);
    }
  }

  List<NotePattern> getLearnedPatterns() {
    return _box.values.where((p) => p.isLearned).toList();
  }
}
