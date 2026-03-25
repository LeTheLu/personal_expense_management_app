import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:du_an/features/transaction/data/repositories/transaction_repository.dart';
import 'package:du_an/features/budget/data/repositories/budget_repository.dart';
import 'package:du_an/features/budget/domain/entities/budget.dart';
import 'package:du_an/features/home/data/repositories/income_source_repository.dart';
import 'package:du_an/features/saving/data/repositories/saving_repository.dart';
import 'package:du_an/features/category/data/repositories/custom_category_repository.dart';
import 'package:du_an/features/settings/data/repositories/app_settings_repository.dart';
import 'package:du_an/features/suggestion/domain/suggestion_engine.dart';
import 'package:du_an/features/suggestion/domain/smart_parse_result.dart';
import 'package:du_an/features/transaction/domain/entities/transaction.dart';
import 'package:du_an/features/home/domain/entities/income_source.dart';
import 'package:du_an/features/saving/domain/entities/saving.dart';
import 'package:du_an/features/home/domain/entities/fixed_expense.dart';
import 'package:du_an/features/home/data/repositories/fixed_expense_repository.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository transactionRepo;
  final BudgetRepository budgetRepo;
  final IncomeSourceRepository incomeSourceRepo;
  final SavingRepository savingRepo;
  final CustomCategoryRepository categoryRepo;
  final AppSettingsRepository settingsRepo;
  final FixedExpenseRepository fixedExpenseRepo;
  final SuggestionEngine suggestionEngine;

  TransactionCubit({
    required this.transactionRepo,
    required this.budgetRepo,
    required this.incomeSourceRepo,
    required this.savingRepo,
    required this.fixedExpenseRepo,
    required this.categoryRepo,
    required this.settingsRepo,
    required this.suggestionEngine,
  }) : super(TransactionState());

  void init() {
    final suggestions = suggestionEngine.getSuggestions();
    final mostLikely = suggestionEngine.getMostLikely();
    emit(state.copyWith(suggestions: suggestions, mostLikely: mostLikely, date: DateTime.now()));
  }

  void updateType(TransactionType type) => emit(state.copyWith(type: type));

  void updateCategory(String category) {
    final amountSugs = suggestionEngine.getAmountSuggestions(category);
    emit(state.copyWith(category: category, amountSuggestions: amountSugs));
  }

  void updateAmount(double amount) => emit(state.copyWith(amount: amount));
  void updateDate(DateTime date) => emit(state.copyWith(date: date));
  void updateNote(String note) => emit(state.copyWith(note: note));
  void updateBudgetId(String? budgetId) => emit(state.copyWith(budgetId: budgetId));
  void updateIncomeSourceId(String? id) => emit(state.copyWith(incomeSourceId: id));
  void updateSmartResult(SmartParseResultV2 result) => emit(state.copyWith(smartResult: result, category: result.category));

  /// Check if a budget exists for this category in current month
  bool hasBudgetForCategory(String categoryName) {
    final now = DateTime.now();
    return budgetRepo.findByName(categoryName, now.month, now.year) != null;
  }

  /// Create a budget for category (or update if exists)
  Future<void> createBudgetForCategory(String categoryName, double limitAmount, int iconCodePoint) async {
    final now = DateTime.now();
    final existing = budgetRepo.findByName(categoryName, now.month, now.year);
    if (existing != null) {
      // Already exists - update limit
      final updated = Budget(
        id: existing.id, name: existing.name,
        limitAmount: limitAmount,
        spentAmount: existing.spentAmount,
        month: existing.month, year: existing.year,
        iconCodePoint: existing.iconCodePoint,
        preferredIncomeSourceId: existing.preferredIncomeSourceId,
        keywords: existing.keywords,
      );
      await budgetRepo.update(updated);
    } else {
      await budgetRepo.add(Budget(
        id: now.millisecondsSinceEpoch.toString(),
        name: categoryName, limitAmount: limitAmount,
        month: now.month, year: now.year,
        iconCodePoint: iconCodePoint,
      ));
    }
  }

  List<Budget> getCurrentBudgets() {
    final now = DateTime.now();
    return budgetRepo.getByMonth(now.month, now.year);
  }

  List<IncomeSource> getAllIncomeSources() => incomeSourceRepo.getAll();

  /// Generate inline suggestions based on current input text
  List<Map<String, dynamic>> _getInlineSuggestions(String input) {
    if (input.trim().isEmpty) return [];

    final settings = settingsRepo.get();
    final lower = _removeDiacritics(input.toLowerCase().trim());
    final lastWord = lower.split(RegExp(r'\s+')).last;
    final suggestions = <Map<String, dynamic>>[];

    // Suggest action keywords matching last word
    for (final kw in [...settings.createKeywords, ...settings.addKeywords, ...settings.deductKeywords]) {
      if (_removeDiacritics(kw).startsWith(lastWord) && _removeDiacritics(kw) != lastWord) {
        final isCreate = settings.createKeywords.contains(kw);
        final isAdd = settings.addKeywords.contains(kw);
        suggestions.add({
          'label': kw,
          'color': isCreate ? 0xFF2E7D32 : (isAdd ? 0xFF4CAF50 : 0xFFE53935),
        });
      }
    }

    // If input contains a create keyword → suggest fund types
    for (final kw in settings.createKeywords) {
      if (lower.contains(_removeDiacritics(kw))) {
        for (final entry in {
          'quỹ chi tiêu': 0xFF2E7D32, 'tích lũy': 0xFF1565C0,
          'chi phí cố định': 0xFFFFA726, 'thu nhập': 0xFF4CAF50,
        }.entries) {
          if (!lower.contains(_removeDiacritics(entry.key))) {
            suggestions.add({'label': entry.key, 'color': entry.value});
          }
        }
        break;
      }
    }

    // Suggest existing fund names matching last word
    if (lastWord.length >= 2) {
      for (final s in incomeSourceRepo.getAll()) {
        if (_removeDiacritics(s.name.toLowerCase()).contains(lastWord)) {
          suggestions.add({'label': s.name, 'color': 0xFF4CAF50});
        }
      }
      for (final s in savingRepo.getAll()) {
        if (_removeDiacritics(s.name.toLowerCase()).contains(lastWord)) {
          suggestions.add({'label': s.name, 'color': 0xFF1565C0});
        }
      }
      for (final b in getCurrentBudgets()) {
        if (_removeDiacritics(b.name.toLowerCase()).contains(lastWord)) {
          suggestions.add({'label': b.name, 'color': 0xFF2E7D32});
        }
      }
    }

    // Deduplicate
    final seen = <String>{};
    return suggestions.where((s) => seen.add(s['label'] as String)).take(6).toList();
  }

  static String _removeDiacritics(String str) {
    const diacritics = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const nonDiacritics = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    var result = str;
    for (int i = 0; i < diacritics.length; i++) {
      result = result.replaceAll(diacritics[i], nonDiacritics[i]);
    }
    return result;
  }

  /// Smart text input V2
  void onSmartInputChanged(String input) {
    // Clear everything when input empty
    if (input.trim().isEmpty) {
      emit(state.copyWith(smartInput: '', smartResult: null, inlineSuggestions: []));
      return;
    }

    final settings = settingsRepo.get();

    // Generate inline suggestions
    final inlineSugs = _getInlineSuggestions(input);

    // Parse input directly
    final result = suggestionEngine.parseSmartInputV2(
      input,
      incomeSources: incomeSourceRepo.getAll(),
      savings: savingRepo.getAll(),
      budgets: getCurrentBudgets(),
      settings: settings,
    );

    if (result != null) {
      emit(state.copyWith(
        smartInput: input,
        smartResult: result,
        amount: result.amount ?? state.amount,
        category: result.category.isNotEmpty ? result.category : state.category,
        note: result.note ?? state.note,
        inlineSuggestions: inlineSugs,
      ));
    } else {
      // Try old simple parse as fallback
      final simple = suggestionEngine.parseSmartInput(input);
      if (simple != null) {
        // Extract text part: remove only the amount portion, keep words intact
        final amountRegex = RegExp(r'\d+(?:[.,]\d+)?\s*(?:k|nghin|tr|trieu)?', caseSensitive: false);
        final textOnly = input.toLowerCase().replaceAll(amountRegex, '').trim();
        final words = textOnly.split(RegExp(r'\s+'));

        // Try matching each word against category AND budget keywords
        String? matchedCategory;
        for (final word in words) {
          if (word.isEmpty || word.length < 2) continue;
          // Check category keywords
          final catMatch = categoryRepo.findByKeyword(word);
          if (catMatch != null) {
            matchedCategory = catMatch.name;
            break;
          }
          // Check budget keywords
          final now = DateTime.now();
          final budgetMatch = budgetRepo.findByKeyword(word, now.month, now.year);
          if (budgetMatch != null) {
            matchedCategory = budgetMatch.name;
            break;
          }
        }
        // If no word matched, try the whole text
        if (matchedCategory == null && textOnly.isNotEmpty) {
          final catMatch = categoryRepo.findByKeyword(textOnly);
          matchedCategory = catMatch?.name;
          if (matchedCategory == null) {
            final now = DateTime.now();
            final budgetMatch = budgetRepo.findByKeyword(textOnly, now.month, now.year);
            matchedCategory = budgetMatch?.name;
          }
        }
        final category = matchedCategory ?? simple.category;
        // Keep original input text with diacritics for note
        final originalNote = input.replaceAll(RegExp(r'\d+(?:[.,]\d+)?\s*(?:k|nghin|tr|trieu)?', caseSensitive: false), '').trim();
        final note = originalNote.isNotEmpty ? originalNote : simple.label;

        // Build SmartParseResultV2 so chips show
        final smartResult = SmartParseResultV2(
          action: SmartAction.expense,
          amount: simple.amount,
          category: category,
          note: note.isNotEmpty ? note : null,
          confidence: 0.8,
          fundExists: hasBudgetForCategory(category),
          fundName: category,
        );

        emit(state.copyWith(
          smartInput: input,
          smartResult: smartResult,
          category: category,
          amount: simple.amount ?? state.amount,
          note: note.isNotEmpty ? note : state.note,
          type: TransactionType.expense,
          inlineSuggestions: inlineSugs,
        ));
      } else {
        emit(state.copyWith(smartInput: input, inlineSuggestions: inlineSugs));
      }
    }
  }

  /// Apply suggestion
  void applySuggestion(Suggestion suggestion) {
    emit(state.copyWith(
      category: suggestion.category,
      amount: suggestion.amount,
      type: TransactionType.expense,
      note: suggestion.label,
    ));
  }

  /// Resolve ambiguity
  void resolveAsAdd() {
    final sr = state.smartResult;
    if (sr == null) return;
    emit(state.copyWith(
      smartResult: SmartParseResultV2(
        action: sr.fundExists ? SmartAction.addToFund : SmartAction.createFund,
        fundName: sr.fundName,
        fundId: sr.fundId,
        fundExists: sr.fundExists,
        fundType: sr.fundType,
        sourceFundName: sr.sourceFundName,
        sourceFundId: sr.sourceFundId,
        amount: sr.amount,
        note: sr.note,
        category: sr.category,
        confidence: 0.9,
      ),
      type: TransactionType.income,
    ));
  }

  void resolveAsExpense() {
    final sr = state.smartResult;
    if (sr == null) return;
    emit(state.copyWith(
      smartResult: SmartParseResultV2(
        action: SmartAction.expense,
        amount: sr.amount,
        note: sr.note ?? sr.fundName,
        category: sr.fundName ?? sr.category,
        confidence: 0.9,
      ),
      type: TransactionType.expense,
    ));
  }

  /// Submit transaction
  Future<void> submit() async {
    // Check smart result first
    final sr = state.smartResult;
    if (sr != null && sr.isComplete) {
      // Handle create actions directly
      if (sr.action == SmartAction.createBudget ||
          sr.action == SmartAction.createSaving ||
          sr.action == SmartAction.createFixedExpense ||
          sr.action == SmartAction.createFund) {
        return _submitCreateAction(sr);
      }

      // For expense smart results, check if budget exists
      if (sr.action == SmartAction.expense && !sr.fundExists) {
        final cat = categoryRepo.getByName(sr.category);
        emit(state.copyWith(
          status: TransactionFormStatus.needsBudgetCreation,
          pendingBudgetCategory: sr.category,
          pendingBudgetIconCodePoint: cat?.iconCodePoint,
        ));
        return;
      }
      return _submitSmart(sr);
    }

    // Normal submit - check category has budget
    if (state.amount <= 0) {
      emit(state.copyWith(errorMessage: 'Vui lòng nhập số tiền'));
      return;
    }

    if (state.type == TransactionType.expense && state.category.isNotEmpty) {
      if (!hasBudgetForCategory(state.category)) {
        final cat = categoryRepo.getByName(state.category);
        emit(state.copyWith(
          status: TransactionFormStatus.needsBudgetCreation,
          pendingBudgetCategory: state.category,
          pendingBudgetIconCodePoint: cat?.iconCodePoint,
        ));
        return;
      }
    }

    emit(state.copyWith(status: TransactionFormStatus.submitting));
    try {
      if (state.type == TransactionType.income && state.incomeSourceId != null) {
        await incomeSourceRepo.addAmount(state.incomeSourceId!, state.amount);
        final transaction = _buildTransaction();
        await transactionRepo.add(transaction);
      } else if (state.type == TransactionType.expense) {
        final transaction = _buildTransaction();
        await transactionRepo.add(transaction);
        await _deductFromBudget(transaction);
      } else {
        await transactionRepo.add(_buildTransaction());
      }

      emit(state.copyWith(status: TransactionFormStatus.success));
    } catch (e) {
      emit(state.copyWith(status: TransactionFormStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _submitCreateAction(SmartParseResultV2 sr) async {
    emit(state.copyWith(status: TransactionFormStatus.submitting));
    try {
      final now = DateTime.now();
      final name = sr.fundName ?? sr.category;

      if (sr.action == SmartAction.createBudget) {
        // Check existing budget with same name this month
        final existing = budgetRepo.findByName(name, now.month, now.year);
        if (existing != null) {
          // Update limit of existing budget
          final updated = Budget(
            id: existing.id, name: existing.name,
            limitAmount: existing.limitAmount + sr.amount!,
            spentAmount: existing.spentAmount,
            month: existing.month, year: existing.year,
            iconCodePoint: existing.iconCodePoint,
            preferredIncomeSourceId: existing.preferredIncomeSourceId,
            keywords: existing.keywords,
          );
          await budgetRepo.update(updated);
        } else {
          await budgetRepo.add(Budget(
            id: now.millisecondsSinceEpoch.toString(),
            name: name, limitAmount: sr.amount!,
            month: now.month, year: now.year,
          ));
        }
      } else if (sr.action == SmartAction.createSaving) {
        // Check existing saving with same name
        final existingSaving = savingRepo.getAll().where((s) =>
            _removeDiacritics(s.name.toLowerCase()) == _removeDiacritics(name.toLowerCase())).firstOrNull;
        if (existingSaving != null) {
          // Add to existing saving target
          final updated = Saving(
            id: existingSaving.id, name: existingSaving.name,
            currentAmount: existingSaving.currentAmount,
            targetAmount: existingSaving.targetAmount + sr.amount!,
            createdAt: existingSaving.createdAt,
            iconCodePoint: existingSaving.iconCodePoint,
          );
          await savingRepo.update(updated);
        } else {
          await savingRepo.add(Saving(
            id: now.millisecondsSinceEpoch.toString(),
            name: name, targetAmount: sr.amount!, createdAt: now,
          ));
        }
        // Also create/update budget if secondary amount (hạn mức) provided
        if (sr.secondaryAmount != null && sr.secondaryAmount! > 0) {
          final existingBudget = budgetRepo.findByName(name, now.month, now.year);
          if (existingBudget == null) {
            await budgetRepo.add(Budget(
              id: (now.millisecondsSinceEpoch + 1).toString(),
              name: name, limitAmount: sr.secondaryAmount!,
              month: now.month, year: now.year,
            ));
          }
        }
      } else if (sr.action == SmartAction.createFixedExpense) {
        final dueDay = (sr.dueDay ?? 1).clamp(1, 31);
        await fixedExpenseRepo.add(FixedExpense(
          id: now.millisecondsSinceEpoch.toString(),
          name: name, amount: sr.amount!,
          dueDate: DateTime(now.year, now.month, dueDay),
          dueDay: dueDay, isRecurring: true,
        ));
      } else if (sr.action == SmartAction.createFund) {
        // Check existing income source with same name
        final existingSource = incomeSourceRepo.getAll().where((s) =>
            _removeDiacritics(s.name.toLowerCase()) == _removeDiacritics(name.toLowerCase())).firstOrNull;
        if (existingSource != null) {
          // Add amount to existing source
          await incomeSourceRepo.addAmount(existingSource.id, sr.amount!);
        } else {
          await incomeSourceRepo.add(IncomeSource(
            id: now.millisecondsSinceEpoch.toString(),
            name: name, amount: sr.amount!, date: now,
          ));
        }
      }

      emit(state.copyWith(status: TransactionFormStatus.success));
    } catch (e) {
      emit(state.copyWith(status: TransactionFormStatus.error, errorMessage: e.toString()));
    }
  }

  void cancelBudgetCreation() {
    emit(state.copyWith(
      status: TransactionFormStatus.initial,
      pendingBudgetCategory: null,
      pendingBudgetIconCodePoint: null,
    ));
  }

  /// Called after user creates budget, then continue submitting
  Future<void> confirmBudgetAndSubmit(double limitAmount) async {
    final category = state.pendingBudgetCategory;
    if (category == null) return;

    await createBudgetForCategory(
      category,
      limitAmount,
      state.pendingBudgetIconCodePoint ?? 0xe25a,
    );

    // Reset pending state and re-submit
    emit(state.copyWith(
      status: TransactionFormStatus.initial,
      pendingBudgetCategory: null,
      pendingBudgetIconCodePoint: null,
    ));

    // Update smart result fundExists if applicable
    final sr = state.smartResult;
    if (sr != null && sr.action == SmartAction.expense) {
      emit(state.copyWith(
        smartResult: SmartParseResultV2(
          action: sr.action,
          fundName: sr.fundName,
          fundExists: true,
          amount: sr.amount,
          note: sr.note,
          category: sr.category,
          confidence: sr.confidence,
        ),
      ));
    }

    await submit();
  }

  Future<void> _submitSmart(SmartParseResultV2 sr) async {
    emit(state.copyWith(status: TransactionFormStatus.submitting));
    try {
      final transaction = TransactionEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: sr.action == SmartAction.expense ? TransactionType.expense : TransactionType.income,
        amount: sr.amount!,
        category: sr.category,
        date: state.date,
        note: sr.note,
        budgetId: sr.fundType == 'budget' ? sr.fundId : null,
      );
      await transactionRepo.add(transaction);

      if (sr.action == SmartAction.addToFund && sr.fundId != null) {
        if (sr.fundType == 'income') {
          await incomeSourceRepo.addAmount(sr.fundId!, sr.amount!);
        } else if (sr.fundType == 'saving') {
          await savingRepo.addAmount(sr.fundId!, sr.amount!);
          // Deduct from source if specified
          if (sr.sourceFundId != null) {
            await incomeSourceRepo.deductAmount(sr.sourceFundId!, sr.amount!,
                description: 'Tích lũy "${sr.fundName}" +${sr.amount}');
          }
        }
      } else if (sr.action == SmartAction.expense) {
        await _deductFromBudget(transaction);
      }

      emit(state.copyWith(status: TransactionFormStatus.success));
    } catch (e) {
      emit(state.copyWith(status: TransactionFormStatus.error, errorMessage: e.toString()));
    }
  }

  TransactionEntity _buildTransaction() {
    return TransactionEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: state.type,
      amount: state.amount,
      category: state.category,
      date: state.date,
      note: state.note.isEmpty ? null : state.note,
      budgetId: state.budgetId,
    );
  }

  Future<void> _deductFromBudget(TransactionEntity transaction) async {
    Budget? budget;
    if (transaction.budgetId != null) {
      budget = budgetRepo.getById(transaction.budgetId!);
    } else {
      final now = DateTime.now();
      budget = budgetRepo.findByName(transaction.category, now.month, now.year);
    }

    if (budget != null) {
      final txnDesc = 'Chi tiêu: ${transaction.category} - ${transaction.amount} ${transaction.note != null ? "(${transaction.note})" : ""}';
      await budgetRepo.updateSpent(budget.id, budget.spentAmount + transaction.amount, note: txnDesc);
      await _deductFromIncomeSource(budget.preferredIncomeSourceId, transaction.amount, txnDesc);
    }
  }

  Future<void> _deductFromIncomeSource(String? preferredId, double amount, String description) async {
    final sources = incomeSourceRepo.getAll();
    if (sources.isEmpty) return;

    var remaining = amount;

    if (preferredId != null) {
      final preferred = incomeSourceRepo.getById(preferredId);
      if (preferred != null && preferred.remainingAmount > 0) {
        final deduct = remaining <= preferred.remainingAmount ? remaining : preferred.remainingAmount;
        await incomeSourceRepo.deductAmount(preferredId, deduct, description: description);
        remaining -= deduct;
      }
    }

    if (remaining > 0) {
      final sorted = sources.where((s) => s.id != preferredId && s.remainingAmount > 0).toList()
        ..sort((a, b) => b.remainingAmount.compareTo(a.remainingAmount));
      for (final source in sorted) {
        if (remaining <= 0) break;
        final deduct = remaining <= source.remainingAmount ? remaining : source.remainingAmount;
        await incomeSourceRepo.deductAmount(source.id, deduct, description: '$description (từ ${source.name})');
        remaining -= deduct;
      }
    }
  }

  /// Delete transaction with refund
  Future<void> deleteTransaction(TransactionEntity t) async {
    // Reverse budget spent
    if (t.type == TransactionType.expense) {
      Budget? budget;
      if (t.budgetId != null) {
        budget = budgetRepo.getById(t.budgetId!);
      } else {
        final now = DateTime.now();
        budget = budgetRepo.findByName(t.category, now.month, now.year);
      }
      if (budget != null && budget.spentAmount > 0) {
        final newSpent = (budget.spentAmount - t.amount).clamp(0.0, double.infinity);
        await budgetRepo.updateSpent(budget.id, newSpent, note: 'Hoàn trả: xóa giao dịch "${t.note ?? t.category}" -${t.amount}');
      }
    }
    await transactionRepo.delete(t.id);
  }
}
