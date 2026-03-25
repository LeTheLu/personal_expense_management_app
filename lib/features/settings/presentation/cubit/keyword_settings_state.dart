import 'package:equatable/equatable.dart';
import 'package:du_an/features/category/domain/entities/custom_category.dart';
import 'package:du_an/features/budget/domain/entities/budget.dart';
import 'package:du_an/features/settings/domain/entities/app_settings.dart';

class KeywordSettingsState extends Equatable {
  final List<CustomCategory> categories;
  final List<Budget> budgets;
  final AppSettings settings;
  final String? error;

  const KeywordSettingsState({
    this.categories = const [],
    this.budgets = const [],
    this.settings = const AppSettings(),
    this.error,
  });

  KeywordSettingsState copyWith({
    List<CustomCategory>? categories,
    List<Budget>? budgets,
    AppSettings? settings,
    String? error,
  }) {
    return KeywordSettingsState(
      categories: categories ?? this.categories,
      budgets: budgets ?? this.budgets,
      settings: settings ?? this.settings,
      error: error,
    );
  }

  @override
  List<Object?> get props => [categories, budgets, settings, error];
}
