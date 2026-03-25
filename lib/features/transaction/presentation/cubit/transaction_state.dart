import 'package:equatable/equatable.dart';
import 'package:du_an/features/transaction/domain/entities/transaction.dart';
import 'package:du_an/features/suggestion/domain/suggestion_engine.dart';
import 'package:du_an/features/suggestion/domain/smart_parse_result.dart';

enum TransactionFormStatus { initial, submitting, success, error, needsBudgetCreation }

class TransactionState extends Equatable {
  final TransactionFormStatus status;
  final TransactionType type;
  final String category;
  final double amount;
  final DateTime date;
  final String note;
  final String? budgetId;
  final String? incomeSourceId;
  final String? savingId;

  // Smart input
  final String smartInput;
  final SmartParseResultV2? smartResult;
  final List<Suggestion> suggestions;
  final List<double> amountSuggestions;
  final Suggestion? mostLikely;
  final String? errorMessage;
  final String? pendingBudgetCategory;
  final int? pendingBudgetIconCodePoint;
  final List<Map<String, dynamic>> inlineSuggestions;

  TransactionState({
    this.status = TransactionFormStatus.initial,
    this.type = TransactionType.expense,
    this.category = '',
    this.amount = 0,
    DateTime? date,
    this.note = '',
    this.budgetId,
    this.incomeSourceId,
    this.savingId,
    this.smartInput = '',
    this.smartResult,
    this.suggestions = const [],
    this.amountSuggestions = const [],
    this.mostLikely,
    this.errorMessage,
    this.pendingBudgetCategory,
    this.pendingBudgetIconCodePoint,
    this.inlineSuggestions = const [],
  }) : date = date ?? DateTime.now();

  @override
  List<Object?> get props => [
        status, type, category, amount, date, note, budgetId,
        incomeSourceId, savingId, smartInput, smartResult,
        suggestions, amountSuggestions, errorMessage, inlineSuggestions,
      ];

  TransactionState copyWith({
    TransactionFormStatus? status,
    TransactionType? type,
    String? category,
    double? amount,
    DateTime? date,
    String? note,
    String? budgetId,
    String? incomeSourceId,
    String? savingId,
    String? smartInput,
    SmartParseResultV2? smartResult,
    List<Suggestion>? suggestions,
    List<double>? amountSuggestions,
    Suggestion? mostLikely,
    String? errorMessage,
    String? pendingBudgetCategory,
    int? pendingBudgetIconCodePoint,
    List<Map<String, dynamic>>? inlineSuggestions,
  }) {
    return TransactionState(
      status: status ?? this.status,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      budgetId: budgetId ?? this.budgetId,
      incomeSourceId: incomeSourceId ?? this.incomeSourceId,
      savingId: savingId ?? this.savingId,
      smartInput: smartInput ?? this.smartInput,
      smartResult: smartResult ?? this.smartResult,
      suggestions: suggestions ?? this.suggestions,
      amountSuggestions: amountSuggestions ?? this.amountSuggestions,
      mostLikely: mostLikely ?? this.mostLikely,
      errorMessage: errorMessage ?? this.errorMessage,
      pendingBudgetCategory: pendingBudgetCategory ?? this.pendingBudgetCategory,
      pendingBudgetIconCodePoint: pendingBudgetIconCodePoint ?? this.pendingBudgetIconCodePoint,
      inlineSuggestions: inlineSuggestions ?? this.inlineSuggestions,
    );
  }
}
