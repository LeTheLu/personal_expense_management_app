import 'package:du_an/features/transaction/data/repositories/transaction_repository.dart';
import 'package:du_an/features/suggestion/domain/smart_parse_result.dart';
import 'package:du_an/features/home/domain/entities/income_source.dart';
import 'package:du_an/features/saving/domain/entities/saving.dart';
import 'package:du_an/features/budget/domain/entities/budget.dart';
import 'package:du_an/features/settings/domain/entities/app_settings.dart';

class Suggestion {
  final String category;
  final String? subCategory;
  final double amount;
  final double confidence; // 0.0 - 1.0
  final String label;
  final SuggestionSource source;

  const Suggestion({
    required this.category,
    this.subCategory,
    required this.amount,
    required this.confidence,
    required this.label,
    required this.source,
  });
}

enum SuggestionSource { timeBased, history, habit, smart }

class SuggestionEngine {
  final TransactionRepository transactionRepository;

  SuggestionEngine({required this.transactionRepository});

  // Category keywords for smart text parsing (Vietnamese)
  static const Map<String, List<String>> _categoryKeywords = {
    'Ăn uống': ['an', 'com', 'pho', 'bun', 'cafe', 'tra', 'nuoc', 'banh', 'sua', 'do an', 'an sang', 'an trua', 'an toi', 'coffee', 'tra sua', 'bia', 'nhau'],
    'Di chuyển': ['xang', 'grab', 'taxi', 'xe', 'giu xe', 'gui xe', 'dau', 'bus'],
    'Mua sắm': ['mua', 'quan ao', 'giay', 'shopee', 'lazada', 'tiki', 'do dung'],
    'Giải trí': ['phim', 'game', 'nhac', 'karaoke', 'du lich', 'choi'],
    'Sức khỏe': ['thuoc', 'kham', 'benh vien', 'nha thuoc', 'bac si', 'gym'],
    'Học tập': ['sach', 'khoa hoc', 'hoc', 'thi', 'truong'],
    'Hóa đơn': ['dien', 'nuoc', 'mang', 'internet', 'dien thoai', 'wifi'],
    'Khác': [],
  };

  // Time-based suggestions
  static const Map<String, List<Map<String, dynamic>>> _timeSuggestions = {
    'morning': [
      {'category': 'Ăn uống', 'label': 'Ăn sáng', 'amount': 30000},
      {'category': 'Ăn uống', 'label': 'Cafe', 'amount': 25000},
    ],
    'noon': [
      {'category': 'Ăn uống', 'label': 'Ăn trưa', 'amount': 50000},
      {'category': 'Ăn uống', 'label': 'Trà sữa', 'amount': 35000},
    ],
    'afternoon': [
      {'category': 'Ăn uống', 'label': 'Cafe chiều', 'amount': 30000},
    ],
    'evening': [
      {'category': 'Ăn uống', 'label': 'Ăn tối', 'amount': 60000},
      {'category': 'Di chuyển', 'label': 'Grab về', 'amount': 30000},
    ],
    'night': [
      {'category': 'Ăn uống', 'label': 'Ăn khuya', 'amount': 40000},
    ],
  };

  String _getTimeSlot(int hour) {
    if (hour >= 5 && hour < 10) return 'morning';
    if (hour >= 10 && hour < 13) return 'noon';
    if (hour >= 13 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }

  /// Get all suggestions ranked by confidence
  List<Suggestion> getSuggestions() {
    final suggestions = <Suggestion>[];
    final now = DateTime.now();

    // 1. Time-based
    final timeSlot = _getTimeSlot(now.hour);
    final timeSugs = _timeSuggestions[timeSlot] ?? [];
    for (final s in timeSugs) {
      suggestions.add(Suggestion(
        category: s['category'] as String,
        amount: (s['amount'] as int).toDouble(),
        confidence: 0.5,
        label: s['label'] as String,
        source: SuggestionSource.timeBased,
      ));
    }

    // 2. History-based (frequent patterns)
    final patterns = transactionRepository.getFrequentPatterns();
    for (final p in patterns.take(5)) {
      final count = p['count'] as int;
      final confidence = (count / 30.0).clamp(0.3, 0.95);
      suggestions.add(Suggestion(
        category: p['category'] as String,
        amount: p['amount'] as double,
        confidence: confidence,
        label: p['category'] as String,
        source: SuggestionSource.history,
      ));
    }

    // 3. Habit-based (same hour patterns)
    final hourPatterns = _getHourPatterns(now.hour);
    for (final p in hourPatterns) {
      suggestions.add(Suggestion(
        category: p['category'] as String,
        amount: p['amount'] as double,
        confidence: p['confidence'] as double,
        label: '${p['category']} (thường lệ)',
        source: SuggestionSource.habit,
      ));
    }

    // Deduplicate and sort by confidence
    final seen = <String>{};
    final unique = <Suggestion>[];
    for (final s in suggestions) {
      final key = '${s.category}_${s.amount.round()}';
      if (!seen.contains(key)) {
        seen.add(key);
        unique.add(s);
      }
    }
    unique.sort((a, b) => b.confidence.compareTo(a.confidence));

    return unique.take(8).toList();
  }

  List<Map<String, dynamic>> _getHourPatterns(int hour) {
    final all = transactionRepository.getAll();
    final hourTxns = all.where((t) => t.date.hour >= hour - 1 && t.date.hour <= hour + 1);

    final patterns = <String, Map<String, dynamic>>{};
    for (final t in hourTxns) {
      final key = t.category;
      if (patterns.containsKey(key)) {
        patterns[key]!['count'] = (patterns[key]!['count'] as int) + 1;
        patterns[key]!['totalAmount'] = (patterns[key]!['totalAmount'] as double) + t.amount;
      } else {
        patterns[key] = {
          'category': t.category,
          'totalAmount': t.amount,
          'count': 1,
        };
      }
    }

    return patterns.values.map((p) {
      final count = p['count'] as int;
      final avgAmount = (p['totalAmount'] as double) / count;
      return {
        'category': p['category'],
        'amount': avgAmount,
        'confidence': (count / 15.0).clamp(0.3, 0.9),
      };
    }).toList()
      ..sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));
  }

  /// Get amount suggestions for a category
  List<double> getAmountSuggestions(String category) {
    final txns = transactionRepository.getByCategory(category);
    if (txns.isEmpty) return [25000, 30000, 50000];

    final amounts = txns.map((t) => t.amount).toList()..sort();
    final avg = amounts.fold(0.0, (sum, a) => sum + a) / amounts.length;

    // Return: slightly less, average, slightly more
    return [
      _roundToK(avg * 0.8),
      _roundToK(avg),
      _roundToK(avg * 1.2),
    ];
  }

  /// Parse smart text input: "an sang 30k" -> {category, amount}
  SmartParseResult? parseSmartInput(String input) {
    final lower = _removeDiacritics(input.toLowerCase().trim());
    if (lower.isEmpty) return null;

    // Extract amount
    double? amount;
    String textPart = lower;

    // Match patterns: "30k", "30000", "30.000", "50 nghin"
    final amountRegex = RegExp(r'(\d+(?:[.,]\d+)?)\s*(k|nghin|tr|trieu)?');
    final match = amountRegex.firstMatch(lower);
    if (match != null) {
      var num = double.tryParse(match.group(1)!.replaceAll(',', '.')) ?? 0;
      final unit = match.group(2);
      if (unit == 'k' || unit == 'nghin') {
        num *= 1000;
      } else if (unit == 'tr' || unit == 'trieu') {
        num *= 1000000;
      } else if (num < 1000) {
        num = 0; // Skip small numbers without unit
      }
      if (num > 0) {
        amount = num;
        textPart = lower.replaceAll(match.group(0)!, '').trim();
      }
    }

    // Match category
    String? category;
    for (final entry in _categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (keyword.length >= 2 && RegExp('\\b$keyword\\b').hasMatch(textPart)) {
          category = entry.key;
          break;
        }
      }
      if (category != null) break;
    }

    if (category == null && amount == null) return null;

    return SmartParseResult(
      category: category ?? 'Khác',
      amount: amount,
      label: textPart.isNotEmpty ? textPart : category ?? '',
    );
  }

  /// Parse bulk input: "cafe 30k, an trua 50k"
  List<SmartParseResult> parseBulkInput(String input) {
    final parts = input.split(RegExp(r'[,;]'));
    final results = <SmartParseResult>[];
    for (final part in parts) {
      final result = parseSmartInput(part.trim());
      if (result != null) results.add(result);
    }
    return results;
  }

  /// Get the most likely transaction (Zero Input Mode)
  Suggestion? getMostLikely() {
    final suggestions = getSuggestions();
    if (suggestions.isEmpty) return null;
    final top = suggestions.first;
    return top.confidence >= 0.7 ? top : null;
  }

  /// V2 Smart Parse: handles fund matching, action detection, source specification
  SmartParseResultV2? parseSmartInputV2(
    String input, {
    required List<IncomeSource> incomeSources,
    required List<Saving> savings,
    required List<Budget> budgets,
    required AppSettings settings,
  }) {
    if (input.trim().isEmpty) return null;
    final originalInput = input.trim();
    final lower = _removeDiacritics(originalInput.toLowerCase());

    // 1. Extract amounts (may have multiple: "30tr hạn mức 4tr")
    double? amount;
    double? secondaryAmount;
    String textPart = lower;
    final amountRegex = RegExp(r'(\d+(?:[.,]\d+)?)\s*(k|nghin|tr|trieu)?');

    // Check for "han muc X" pattern first
    final limitMatch = RegExp(r'han muc\s+(\d+(?:[.,]\d+)?)\s*(k|nghin|tr|trieu)?').firstMatch(lower);
    if (limitMatch != null) {
      var num = double.tryParse(limitMatch.group(1)!.replaceAll(',', '.')) ?? 0;
      final unit = limitMatch.group(2);
      if (unit == 'k' || unit == 'nghin') num *= 1000;
      if (unit == 'tr' || unit == 'trieu') num *= 1000000;
      secondaryAmount = num;
      textPart = textPart.replaceAll(limitMatch.group(0)!, '').trim();
    }

    // Extract primary amount - scan all matches, pick the valid one
    // Must have unit (k/tr/triệu) OR be >= 1000 to avoid grabbing "3" from "tháng 3"
    final allAmountMatches = amountRegex.allMatches(textPart);
    for (final amountMatch in allAmountMatches) {
      var num = double.tryParse(amountMatch.group(1)!.replaceAll(',', '.')) ?? 0;
      final unit = amountMatch.group(2);
      if (unit == 'k' || unit == 'nghin') {
        num *= 1000;
      } else if (unit == 'tr' || unit == 'trieu') {
        num *= 1000000;
      } else if (num < 1000) {
        continue; // Skip small numbers without unit
      }
      if (num > 0) {
        amount = num;
        textPart = textPart.replaceAll(amountMatch.group(0)!, '').trim();
        break; // Take first valid amount
      }
    }

    // 2. Detect action
    SmartAction? action;
    int? parsedDueDay;

    // 2a. Check "create" keyword first: "tao" + type keyword → determine what to create
    final createNorm = settings.createKeywords.map(_removeDiacritics).toList()..sort((a, b) => b.length.compareTo(a.length));
    bool isCreateAction = false;
    for (final kw in createNorm) {
      if (textPart.startsWith(kw)) {
        isCreateAction = true;
        textPart = textPart.substring(kw.length).trim();
        break;
      }
    }

    if (isCreateAction) {
      // Now detect fund type keyword: "quỹ", "tích lũy", "chi phí", "thu nhập"
      final typeChecks = <List<String>, SmartAction>{
        settings.fixedExpenseTypeKeywords: SmartAction.createFixedExpense,
        settings.savingTypeKeywords: SmartAction.createSaving,
        settings.budgetTypeKeywords: SmartAction.createBudget,
        settings.incomeTypeKeywords: SmartAction.createFund,
      };
      for (final entry in typeChecks.entries) {
        final keywords = entry.key.map(_removeDiacritics).toList()..sort((a, b) => b.length.compareTo(a.length));
        for (final kw in keywords) {
          if (textPart.startsWith(kw)) {
            action = entry.value;
            textPart = textPart.substring(kw.length).trim();
            break;
          }
        }
        if (action != null) break;
      }
      // If "tao" detected but no type → default to createBudget
      action ??= SmartAction.createBudget;
    }

    // Extract due day for fixed expense: "ngay 5", "ngay 15"
    if (action == SmartAction.createFixedExpense) {
      final dayMatch = RegExp(r'ngay\s*(\d{1,2})').firstMatch(textPart);
      if (dayMatch != null) {
        parsedDueDay = int.tryParse(dayMatch.group(1)!);
        textPart = textPart.replaceAll(dayMatch.group(0)!, '').trim();
      }
    }

    // Add keywords
    if (action == null) {
      final addNorm = settings.addKeywords.map(_removeDiacritics).toList()..sort((a, b) => b.length.compareTo(a.length));
      for (final kw in addNorm) {
        if (textPart.startsWith(kw) || textPart.contains(' $kw ')) {
          action = SmartAction.addToFund;
          textPart = textPart.replaceFirst(kw, '').trim();
          break;
        }
      }
    }

    // Deduct keywords
    if (action == null) {
      final deductNorm = settings.deductKeywords.map(_removeDiacritics).toList()..sort((a, b) => b.length.compareTo(a.length));
      for (final kw in deductNorm) {
        if (textPart.startsWith(kw) || textPart.contains(' $kw ')) {
          action = SmartAction.expense;
          textPart = textPart.replaceFirst(kw, '').trim();
          break;
        }
      }
    }

    // 3. Extract note ("noi dung la" / "nd:" / text after main content)
    String? note;
    final notePatterns = [
      RegExp(r'noi dung (?:la )?(.+)$'),
      RegExp(r'nd[:\s]+(.+)$'),
    ];
    for (final pattern in notePatterns) {
      final noteMatch = pattern.firstMatch(textPart);
      if (noteMatch != null) {
        note = noteMatch.group(1)?.trim();
        textPart = textPart.replaceAll(noteMatch.group(0)!, '').trim();
        break;
      }
    }

    // 4. Extract source ("tu nguon thu X", "trich tu X", "tu thu nhap X")
    String? sourceFundName;
    String? sourceFundId;
    final sourcePatterns = [
      RegExp(r'(?:trich |lay )?tu (?:nguon )?(?:thu (?:nhap )?)?(.+?)$'),
      RegExp(r'trich (?:tu )?(.+?)$'),
    ];
    RegExpMatch? sourceMatch;
    for (final pattern in sourcePatterns) {
      sourceMatch = pattern.firstMatch(textPart);
      if (sourceMatch != null) break;
    }
    if (sourceMatch != null) {
      final srcText = sourceMatch.group(1)?.trim();
      if (srcText != null && srcText.isNotEmpty) {
        sourceFundName = srcText;
        textPart = textPart.replaceAll(sourceMatch.group(0)!, '').trim();
        // Try match source
        for (final s in incomeSources) {
          if (_removeDiacritics(s.name.toLowerCase()).contains(_removeDiacritics(srcText))) {
            sourceFundId = s.id;
            sourceFundName = s.name;
            break;
          }
        }
      }
    }

    // 5. Clean up common filler words (keep "quy" for context)
    textPart = textPart
        .replaceAll(RegExp(r'\b(vao|cho|nguon)\b'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    // Remove leading "quy" only (it's a prefix, not part of the name)
    if (textPart.startsWith('quy ')) {
      textPart = textPart.substring(4).trim();
    }

    // 6. Fund matching
    String? fundName;
    String? fundId;
    String? fundType;
    bool fundExists = false;

    if (textPart.isNotEmpty) {
      final textNorm = _removeDiacritics(textPart);

      // Match income sources
      for (final s in incomeSources) {
        if (_removeDiacritics(s.name.toLowerCase()).contains(textNorm) || textNorm.contains(_removeDiacritics(s.name.toLowerCase()))) {
          fundName = s.name;
          fundId = s.id;
          fundType = 'income';
          fundExists = true;
          break;
        }
      }

      // Match savings
      if (!fundExists) {
        for (final s in savings) {
          if (_removeDiacritics(s.name.toLowerCase()).contains(textNorm) || textNorm.contains(_removeDiacritics(s.name.toLowerCase()))) {
            fundName = s.name;
            fundId = s.id;
            fundType = 'saving';
            fundExists = true;
            break;
          }
        }
      }

      // Match budgets
      if (!fundExists) {
        for (final b in budgets) {
          if (_removeDiacritics(b.name.toLowerCase()).contains(textNorm) || textNorm.contains(_removeDiacritics(b.name.toLowerCase()))) {
            fundName = b.name;
            fundId = b.id;
            fundType = 'budget';
            fundExists = true;
            break;
          }
        }
      }

      if (!fundExists) {
        fundName = textPart;
      }
    }

    // 7. Determine action if not yet detected
    if (action == null && amount != null) {
      // First try category keywords for expense detection
      String? matchedCategory;
      for (final entry in _categoryKeywords.entries) {
        for (final keyword in entry.value) {
          if (keyword.length >= 2 && RegExp('\\b$keyword\\b').hasMatch(lower)) {
            matchedCategory = entry.key;
            break;
          }
        }
        if (matchedCategory != null) break;
      }

      if (matchedCategory != null) {
        // Keyword matched a category → this is an expense
        return SmartParseResultV2(
          action: SmartAction.expense,
          amount: amount,
          category: matchedCategory,
          note: note ?? _extractOriginalNote(originalInput),
          fundName: matchedCategory,
          fundExists: budgets.any((b) => _removeDiacritics(b.name.toLowerCase()) == _removeDiacritics(matchedCategory!.toLowerCase())),
          confidence: 0.8,
        );
      } else if (fundName != null) {
        action = SmartAction.ambiguous;
      } else {
        return null;
      }
    }

    if (action == null) return null;

    // 8. If addToFund and fund doesn't exist → createFund
    if (action == SmartAction.addToFund && !fundExists && fundName != null) {
      action = SmartAction.createFund;
    }

    // For create actions, use textPart as fundName if not matched
    if ((action == SmartAction.createBudget || action == SmartAction.createSaving || action == SmartAction.createFixedExpense) && fundName == null && textPart.isNotEmpty) {
      fundName = textPart;
    }

    // Build original note with diacritics: strip amounts/keywords from original input
    final originalNote = note ?? _extractOriginalNote(originalInput);
    // fundName with diacritics: find matching portion in original input
    final originalFundName = fundName != null ? _findOriginalText(originalInput, fundName) : null;

    return SmartParseResultV2(
      action: action,
      fundName: originalFundName ?? fundName,
      fundId: fundId,
      fundExists: fundExists,
      fundType: fundType,
      sourceFundName: sourceFundName,
      sourceFundId: sourceFundId,
      amount: amount,
      note: originalNote,
      category: originalFundName ?? fundName ?? '',
      confidence: fundExists ? 0.9 : 0.5,
      dueDay: parsedDueDay,
      secondaryAmount: secondaryAmount,
    );
  }

  /// Extract note from original input (with diacritics), stripping amounts
  String? _extractOriginalNote(String original) {
    var text = original;
    // Remove amounts
    text = text.replaceAll(RegExp(r'\d+(?:[.,]\d+)?\s*(?:k|nghìn|nghin|tr|triệu|trieu)?', caseSensitive: false), '');
    // Remove "hạn mức" pattern
    text = text.replaceAll(RegExp(r'hạn mức|han muc', caseSensitive: false), '');
    // Remove "ngày X"
    text = text.replaceAll(RegExp(r'ngày\s*\d+|ngay\s*\d+', caseSensitive: false), '');
    // Remove common filler
    text = text.replaceAll(RegExp(r'\b(vào|cho|từ|nguồn|thu nhập|nội dung là|nội dung)\b', caseSensitive: false), '');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text.isEmpty ? null : text;
  }

  /// Find the original (with diacritics) version of a normalized text in the original input
  String _findOriginalText(String original, String normalizedTarget) {
    final words = original.split(RegExp(r'\s+'));
    final targetNorm = _removeDiacritics(normalizedTarget.toLowerCase());

    // Try to find consecutive words that match
    for (int start = 0; start < words.length; start++) {
      for (int end = start + 1; end <= words.length; end++) {
        final chunk = words.sublist(start, end).join(' ');
        if (_removeDiacritics(chunk.toLowerCase()) == targetNorm) {
          return chunk;
        }
      }
    }
    // Fallback: return as-is
    return normalizedTarget;
  }

  double _roundToK(double value) {
    return (value / 1000).round() * 1000.0;
  }

  String _removeDiacritics(String str) {
    const diacritics = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const nonDiacritics = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';

    var result = str;
    for (int i = 0; i < diacritics.length; i++) {
      result = result.replaceAll(diacritics[i], nonDiacritics[i]);
    }
    return result;
  }
}

class SmartParseResult {
  final String category;
  final double? amount;
  final String label;

  const SmartParseResult({
    required this.category,
    this.amount,
    required this.label,
  });
}
