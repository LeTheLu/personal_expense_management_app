import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/currency_input_formatter.dart';
import 'package:du_an/core/widgets/icon_picker.dart';
import 'package:du_an/core/services/icon_registry.dart';
import 'package:du_an/di/injection.dart';

class AddFixedExpenseResult {
  final String name;
  final double amount;
  final IconData icon;
  final int dueDay;
  final bool isRecurring;

  const AddFixedExpenseResult({
    required this.name,
    required this.amount,
    required this.icon,
    required this.dueDay,
    required this.isRecurring,
  });
}

class AddFixedExpenseDialog extends StatefulWidget {
  const AddFixedExpenseDialog({super.key});

  @override
  State<AddFixedExpenseDialog> createState() => _AddFixedExpenseDialogState();
}

class _AddFixedExpenseDialogState extends State<AddFixedExpenseDialog> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _dueDayCtrl = TextEditingController(text: '1');
  IconData _selectedIcon = Icons.home;
  bool _isRecurring = true;

  static const _icons = [
    Icons.home, Icons.bolt, Icons.water_drop, Icons.wifi,
    Icons.phone, Icons.fitness_center, Icons.subscriptions, Icons.credit_card,
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _dueDayCtrl.dispose();
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
              const Text('Thêm chi phí cố định', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Tên chi phí',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                decoration: InputDecoration(
                  labelText: 'Số tiền',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  suffixText: 'VND',
                ),
              ),
              const SizedBox(height: 12),

              // Due day
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dueDayCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Ngày thanh toán (1-31)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Recurring toggle
              GestureDetector(
                onTap: () => setState(() => _isRecurring = !_isRecurring),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _isRecurring ? AppColors.primary.withValues(alpha: 0.08) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _isRecurring ? AppColors.primary : Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isRecurring ? Icons.check_box : Icons.check_box_outline_blank,
                        size: 20,
                        color: _isRecurring ? AppColors.primary : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Lặp lại hàng tháng', style: TextStyle(fontSize: 13))),
                      if (_isRecurring)
                        const Icon(Icons.repeat, size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Icon picker
              IconPicker(
                suggestedIcons: _icons,
                selectedIcon: _selectedIcon,
                usedIcons: getIt<IconRegistry>().getUsedIconCodePoints(),
                onSelected: (icon) => setState(() => _selectedIcon = icon),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final name = _nameCtrl.text.trim();
                      final amount = CurrencyInputFormatter.parse(_amountCtrl.text);
                      final dueDay = int.tryParse(_dueDayCtrl.text.trim()) ?? 1;
                      if (name.isNotEmpty && amount > 0 && dueDay >= 1 && dueDay <= 31) {
                        Navigator.pop(context, AddFixedExpenseResult(
                          name: name,
                          amount: amount,
                          icon: _selectedIcon,
                          dueDay: dueDay.clamp(1, 31),
                          isRecurring: _isRecurring,
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Thêm'),
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
