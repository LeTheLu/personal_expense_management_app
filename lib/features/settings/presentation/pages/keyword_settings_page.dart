import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/di/injection.dart';
import 'package:du_an/core/utils/date_utils.dart';
import 'package:du_an/core/services/keyword_validator.dart';
import 'package:du_an/features/category/data/repositories/custom_category_repository.dart';
import 'package:du_an/features/budget/data/repositories/budget_repository.dart';
import 'package:du_an/features/settings/data/repositories/app_settings_repository.dart';
import 'package:du_an/features/settings/presentation/cubit/keyword_settings_cubit.dart';
import 'package:du_an/features/settings/presentation/cubit/keyword_settings_state.dart';
import 'package:du_an/features/category/domain/entities/custom_category.dart';
import 'package:du_an/features/budget/domain/entities/budget.dart';

class KeywordSettingsPage extends StatelessWidget {
  const KeywordSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => KeywordSettingsCubit(
        categoryRepo: getIt<CustomCategoryRepository>(),
        budgetRepo: getIt<BudgetRepository>(),
        settingsRepo: getIt<AppSettingsRepository>(),
        keywordValidator: getIt<KeywordValidator>(),
      )..load(),
      child: const _KeywordSettingsView(),
    );
  }
}

class _KeywordSettingsView extends StatelessWidget {
  const _KeywordSettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Từ khóa thông minh')),
      body: BlocConsumer<KeywordSettingsCubit, KeywordSettingsState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!), backgroundColor: AppColors.expense),
            );
            context.read<KeywordSettingsCubit>().clearError();
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Salary Day
                _sectionTitle('Ngày nhận lương'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('Ngày nhận lương hàng tháng', style: TextStyle(fontSize: 14))),
                      GestureDetector(
                        onTap: () => _pickSalaryDay(context, state.settings.salaryDay),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Ngày ${state.settings.salaryDay}',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Add Keywords
                _sectionTitle('Từ khóa "Thêm / Cộng"'),
                const SizedBox(height: 8),
                _keywordChips(
                  context,
                  keywords: state.settings.addKeywords,
                  color: AppColors.income,
                  onRemove: (k) => context.read<KeywordSettingsCubit>().removeActionKeyword(k, isAdd: true),
                  onAdd: () => _showAddKeywordDialog(context, 'Thêm từ khóa cộng', (k) {
                    context.read<KeywordSettingsCubit>().addActionKeyword(k, isAdd: true);
                  }),
                ),
                const SizedBox(height: 16),

                // Deduct Keywords
                _sectionTitle('Từ khóa "Chi / Trừ"'),
                const SizedBox(height: 8),
                _keywordChips(
                  context,
                  keywords: state.settings.deductKeywords,
                  color: AppColors.expense,
                  onRemove: (k) => context.read<KeywordSettingsCubit>().removeActionKeyword(k, isAdd: false),
                  onAdd: () => _showAddKeywordDialog(context, 'Thêm từ khóa trừ', (k) {
                    context.read<KeywordSettingsCubit>().addActionKeyword(k, isAdd: false);
                  }),
                ),
                const SizedBox(height: 16),

                // Create Keywords (shared)
                _sectionTitle('Từ khóa "Tạo"'),
                const SizedBox(height: 8),
                _keywordChips(context,
                  keywords: state.settings.createKeywords,
                  color: AppColors.primary,
                  onRemove: (k) => context.read<KeywordSettingsCubit>().removeCreateKeyword(k),
                  onAdd: () => _showAddKeywordDialog(context, 'Thêm từ khóa tạo', (k) {
                    context.read<KeywordSettingsCubit>().addCreateKeyword(k);
                  }),
                ),
                const SizedBox(height: 16),

                // Fund type keywords
                _sectionTitle('Từ khóa loại quỹ'),
                const SizedBox(height: 8),
                _typeKeywordSection(context, 'Quỹ chi tiêu', state.settings.budgetTypeKeywords, AppColors.primary, 'budget'),
                _typeKeywordSection(context, 'Tích lũy', state.settings.savingTypeKeywords, AppColors.secondary, 'saving'),
                _typeKeywordSection(context, 'Chi phí cố định', state.settings.fixedExpenseTypeKeywords, AppColors.warning, 'fixed'),
                _typeKeywordSection(context, 'Thu nhập', state.settings.incomeTypeKeywords, AppColors.income, 'income'),
                const SizedBox(height: 24),

                // Category Keywords
                _sectionTitle('Từ khóa danh mục'),
                const SizedBox(height: 8),
                ...state.categories.map((cat) => _categoryKeywordSection(context, cat)),

                // Budget Keywords (only budgets that DON'T match a category name)
                ..._filteredBudgets(state).isNotEmpty ? [
                  const SizedBox(height: 24),
                  _sectionTitle('Từ khóa quỹ chi tiêu'),
                  const SizedBox(height: 8),
                  ..._filteredBudgets(state).map((b) => _budgetKeywordSection(context, b)),
                ] : [],

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _norm(String s) {
    const d = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const p = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    var r = s.toLowerCase().trim();
    for (int i = 0; i < d.length; i++) r = r.replaceAll(d[i], p[i]);
    return r;
  }

  List<Budget> _filteredBudgets(KeywordSettingsState state) {
    final categoryNames = state.categories.map((c) => _norm(c.name)).toSet();
    return state.budgets.where((b) => !categoryNames.contains(_norm(b.name))).toList();
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget _keywordChips(
    BuildContext context, {
    required List<String> keywords,
    required Color color,
    required ValueChanged<String> onRemove,
    required VoidCallback onAdd,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...keywords.map((k) => Chip(
                label: Text(k, style: TextStyle(fontSize: 12, color: color)),
                deleteIcon: Icon(Icons.close, size: 16, color: color),
                onDeleted: () => onRemove(k),
                backgroundColor: color.withValues(alpha: 0.1),
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
              )),
          ActionChip(
            label: const Text('+', style: TextStyle(fontSize: 14)),
            onPressed: onAdd,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _categoryKeywordSection(BuildContext context, CustomCategory cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(cat.icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              if (cat.isDefault)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Mặc định', style: TextStyle(fontSize: 9, color: AppColors.primary)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...cat.keywords.map((k) => Chip(
                    label: Text(k, style: const TextStyle(fontSize: 11)),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => context.read<KeywordSettingsCubit>().removeCategoryKeyword(cat.id, k),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )),
              ActionChip(
                label: const Icon(Icons.add, size: 14),
                onPressed: () => _showAddKeywordDialog(context, 'Thêm từ khóa cho "${cat.name}"', (k) {
                  context.read<KeywordSettingsCubit>().addKeywordToCategory(cat.id, k);
                }),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeKeywordSection(BuildContext context, String label, List<String> keywords, Color color, String type) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: color)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...keywords.map((k) => Chip(
                    label: Text(k, style: TextStyle(fontSize: 11, color: color)),
                    deleteIcon: Icon(Icons.close, size: 14, color: color),
                    onDeleted: () => context.read<KeywordSettingsCubit>().removeTypeKeyword(k, type: type),
                    backgroundColor: color.withValues(alpha: 0.1),
                    side: BorderSide.none,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )),
              ActionChip(
                label: const Icon(Icons.add, size: 14),
                onPressed: () => _showAddKeywordDialog(context, 'Thêm từ khóa "$label"', (k) {
                  context.read<KeywordSettingsCubit>().addTypeKeyword(k, type: type);
                }),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _budgetKeywordSection(BuildContext context, Budget budget) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(budget.icon, size: 18, color: AppColors.warning),
              const SizedBox(width: 8),
              Expanded(child: Text(budget.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
              Text(AppDateUtils.formatCurrency(budget.limitAmount), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...budget.keywords.map((k) => Chip(
                    label: Text(k, style: const TextStyle(fontSize: 11)),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => context.read<KeywordSettingsCubit>().removeBudgetKeyword(budget.id, k),
                    backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )),
              ActionChip(
                label: const Icon(Icons.add, size: 14),
                onPressed: () => _showAddKeywordDialog(context, 'Thêm từ khóa cho quỹ "${budget.name}"', (k) {
                  context.read<KeywordSettingsCubit>().addKeywordToBudget(budget.id, k);
                }),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _pickSalaryDay(BuildContext context, int currentDay) async {
    final controller = TextEditingController(text: currentDay.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ngày nhận lương'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Ngày (1-31)', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final day = int.tryParse(controller.text) ?? 0;
              if (day >= 1 && day <= 31) Navigator.pop(ctx, day);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    if (result != null && context.mounted) {
      context.read<KeywordSettingsCubit>().updateSalaryDay(result);
    }
  }

  void _showAddKeywordDialog(BuildContext context, String title, ValueChanged<String> onAdd) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nhập từ khóa...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) Navigator.pop(ctx, text);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
    if (result != null) onAdd(result);
  }
}
