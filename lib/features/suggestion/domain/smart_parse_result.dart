enum SmartAction { addToFund, expense, createFund, createBudget, createSaving, createFixedExpense, ambiguous }

class SmartParseResultV2 {
  final SmartAction action;
  final String? fundName;
  final String? fundId;
  final bool fundExists;
  final String? fundType; // 'income', 'saving', 'budget', 'fixed'
  final String? sourceFundName;
  final String? sourceFundId;
  final double? amount;
  final String? note;
  final String category;
  final double confidence;
  final int? dueDay; // for fixed expense
  final double? secondaryAmount; // e.g. monthly limit for saving

  const SmartParseResultV2({
    required this.action,
    this.fundName,
    this.fundId,
    this.fundExists = false,
    this.fundType,
    this.sourceFundName,
    this.sourceFundId,
    this.amount,
    this.note,
    this.category = '',
    this.confidence = 0,
    this.dueDay,
    this.secondaryAmount,
  });

  bool get isComplete {
    if (action == SmartAction.ambiguous) return false;
    if (amount == null || amount! <= 0) return false;
    if (action == SmartAction.addToFund && fundName == null) return false;
    if (action == SmartAction.expense && category.isEmpty) return false;
    if (action == SmartAction.createBudget && fundName == null) return false;
    if (action == SmartAction.createSaving && fundName == null) return false;
    if (action == SmartAction.createFixedExpense && fundName == null) return false;
    return true;
  }

  String get actionLabel => switch (action) {
    SmartAction.addToFund => 'Cộng',
    SmartAction.expense => 'Chi',
    SmartAction.createFund => 'Tạo nguồn thu',
    SmartAction.createBudget => 'Tạo quỹ chi tiêu',
    SmartAction.createSaving => 'Tạo tích lũy',
    SmartAction.createFixedExpense => 'Tạo chi phí cố định',
    SmartAction.ambiguous => '?',
  };
}
