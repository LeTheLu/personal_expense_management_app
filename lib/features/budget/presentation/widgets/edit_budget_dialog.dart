import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/currency_input_formatter.dart';
import 'package:du_an/core/utils/date_utils.dart';
import 'package:du_an/core/widgets/icon_picker.dart';
import 'package:du_an/core/services/icon_registry.dart';
import 'package:du_an/di/injection.dart';
import 'package:du_an/features/budget/domain/entities/budget.dart';
import 'package:du_an/features/home/domain/entities/income_source.dart';

class EditBudgetDialog extends StatefulWidget {
  final Budget budget;
  final List<IncomeSource> incomeSources;

  const EditBudgetDialog({super.key, required this.budget, this.incomeSources = const []});

  @override
  State<EditBudgetDialog> createState() => _EditBudgetDialogState();
}

class _EditBudgetDialogState extends State<EditBudgetDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _limitCtrl;
  late IconData _selectedIcon;
  String? _selectedSourceId;

  static const _icons = [
    Icons.restaurant, Icons.directions_car, Icons.shopping_bag,
    Icons.movie, Icons.local_hospital, Icons.school,
    Icons.sports_esports, Icons.coffee, Icons.pets, Icons.more_horiz,
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.budget.name);
    _limitCtrl = TextEditingController(text: widget.budget.limitAmount.round().toString());
    _selectedIcon = widget.budget.icon;
    _selectedSourceId = widget.budget.preferredIncomeSourceId;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _limitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sửa quỹ chi tiêu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Tên quỹ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _limitCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                decoration: InputDecoration(
                  labelText: 'Hạn mức',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  suffixText: 'VND',
                ),
              ),
              const SizedBox(height: 12),
              IconPicker(
                suggestedIcons: _icons,
                selectedIcon: _selectedIcon,
                usedIcons: getIt<IconRegistry>().getUsedIconCodePoints(),
                onSelected: (icon) => setState(() => _selectedIcon = icon),
              ),

              // Income source preference
              if (widget.incomeSources.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Nguồn tiền ưu tiên trừ:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() => _selectedSourceId = null),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedSourceId == null ? AppColors.primary.withValues(alpha: 0.08) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _selectedSourceId == null ? AppColors.primary : Colors.grey.shade200, width: _selectedSourceId == null ? 1.5 : 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: _selectedSourceId == null ? AppColors.primary : Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Tự động', style: TextStyle(fontSize: 12, color: _selectedSourceId == null ? AppColors.primary : AppColors.textSecondary, fontWeight: _selectedSourceId == null ? FontWeight.w600 : FontWeight.normal))),
                        if (_selectedSourceId == null) const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                ...widget.incomeSources.map((source) {
                  final selected = _selectedSourceId == source.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSourceId = source.id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.income.withValues(alpha: 0.08) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: selected ? AppColors.income : Colors.grey.shade200, width: selected ? 1.5 : 1),
                      ),
                      child: Row(
                        children: [
                          Icon(source.icon, size: 16, color: selected ? AppColors.income : Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Expanded(child: Text(source.name, style: TextStyle(fontSize: 12, color: selected ? AppColors.income : AppColors.textPrimary, fontWeight: selected ? FontWeight.w600 : FontWeight.normal))),
                          Text('Còn: ${AppDateUtils.formatCurrency(source.remainingAmount > 0 ? source.remainingAmount : 0)}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                          if (selected) ...[const SizedBox(width: 4), const Icon(Icons.check_circle, size: 16, color: AppColors.income)],
                        ],
                      ),
                    ),
                  );
                }),
              ],

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final name = _nameCtrl.text.trim();
                      final limit = CurrencyInputFormatter.parse(_limitCtrl.text);
                      if (name.isNotEmpty && limit > 0) {
                        Navigator.pop(context, {
                          'name': name,
                          'limitAmount': limit,
                          'iconCodePoint': _selectedIcon.codePoint,
                          'preferredIncomeSourceId': _selectedSourceId,
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Lưu'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
