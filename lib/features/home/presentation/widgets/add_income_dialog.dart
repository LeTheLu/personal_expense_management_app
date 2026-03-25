import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/currency_input_formatter.dart';
import 'package:du_an/core/utils/date_utils.dart';
import 'package:du_an/features/home/domain/entities/income_source.dart';
import 'package:du_an/core/widgets/icon_picker.dart';
import 'package:du_an/core/services/icon_registry.dart';
import 'package:du_an/di/injection.dart';

/// Result: either 'new' with name/icon/amount, or 'add' with existingId/amount
class AddIncomeResult {
  final bool isNew;
  final String? existingId;
  final String? name;
  final IconData? icon;
  final double amount;

  const AddIncomeResult.newSource({required this.name, required this.icon, required this.amount})
      : isNew = true,
        existingId = null;

  const AddIncomeResult.addToExisting({required this.existingId, required this.amount})
      : isNew = false,
        name = null,
        icon = null;
}

class AddIncomeDialog extends StatefulWidget {
  final List<IncomeSource> existingSources;

  const AddIncomeDialog({super.key, required this.existingSources});

  @override
  State<AddIncomeDialog> createState() => _AddIncomeDialogState();
}

class _AddIncomeDialogState extends State<AddIncomeDialog> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  IconData _selectedIcon = Icons.account_balance_wallet;
  IncomeSource? _selectedExisting;
  bool _isNewMode = true;

  static const _icons = [
    Icons.account_balance_wallet,
    Icons.work,
    Icons.trending_up,
    Icons.savings,
    Icons.card_giftcard,
    Icons.monetization_on,
    Icons.real_estate_agent,
    Icons.laptop,
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
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
              const Text('Thêm nguồn thu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Existing sources suggestions
              if (widget.existingSources.isNotEmpty) ...[
                const Text('Cộng dồn vào nguồn cũ:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.existingSources.map((source) {
                    final selected = _selectedExisting?.id == source.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedExisting = null;
                            _isNewMode = true;
                          } else {
                            _selectedExisting = source;
                            _isNewMode = false;
                            _nameCtrl.text = source.name;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.income.withValues(alpha: 0.15) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected ? AppColors.income : Colors.grey.shade300,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              IconData(source.iconCodePoint, fontFamily: 'MaterialIcons'),
                              size: 16,
                              color: selected ? AppColors.income : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  source.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? AppColors.income : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  AppDateUtils.formatCurrency(source.amount),
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            if (selected) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.add_circle, size: 14, color: AppColors.income),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setState(() {
                    _selectedExisting = null;
                    _isNewMode = true;
                    _nameCtrl.clear();
                  }),
                  child: Row(
                    children: [
                      Icon(
                        _isNewMode ? Icons.radio_button_checked : Icons.radio_button_off,
                        size: 18,
                        color: _isNewMode ? AppColors.primary : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      const Text('Tạo nguồn thu mới', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Name field (only for new)
              if (_isNewMode) ...[
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Tên nguồn thu',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Amount field (always)
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                decoration: InputDecoration(
                  labelText: _isNewMode ? 'Số tiền' : 'Số tiền cộng thêm',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  suffixText: 'VND',
                  helperText: _selectedExisting != null
                      ? 'Hiện tại: ${AppDateUtils.formatCurrency(_selectedExisting!.amount)}'
                      : null,
                  helperStyle: const TextStyle(color: AppColors.income),
                ),
              ),

              // Icon picker (only for new)
              if (_isNewMode) ...[
                const SizedBox(height: 12),
                IconPicker(
                  suggestedIcons: _icons,
                  selectedIcon: _selectedIcon,
                  usedIcons: getIt<IconRegistry>().getUsedIconCodePoints(),
                  onSelected: (icon) => setState(() => _selectedIcon = icon),
                ),
              ],

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(_isNewMode ? 'Thêm mới' : 'Cộng dồn'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final amount = CurrencyInputFormatter.parse(_amountCtrl.text);
    if (amount <= 0) return;

    if (_isNewMode) {
      final name = _nameCtrl.text.trim();
      if (name.isEmpty) return;
      Navigator.pop(context, AddIncomeResult.newSource(name: name, icon: _selectedIcon, amount: amount));
    } else if (_selectedExisting != null) {
      Navigator.pop(context, AddIncomeResult.addToExisting(existingId: _selectedExisting!.id, amount: amount));
    }
  }
}
