import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/currency_input_formatter.dart';
import 'package:du_an/features/home/domain/entities/income_source.dart';
import 'package:du_an/core/widgets/icon_picker.dart';
import 'package:du_an/core/services/icon_registry.dart';
import 'package:du_an/di/injection.dart';

class EditIncomeDialog extends StatefulWidget {
  final IncomeSource source;

  const EditIncomeDialog({super.key, required this.source});

  @override
  State<EditIncomeDialog> createState() => _EditIncomeDialogState();
}

class _EditIncomeDialogState extends State<EditIncomeDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  late IconData _selectedIcon;

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
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.source.name);
    _amountCtrl = TextEditingController(text: widget.source.amount.round().toString());
    _selectedIcon = IconData(widget.source.iconCodePoint, fontFamily: 'MaterialIcons');
  }

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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sửa nguồn thu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Tên',
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
                    if (name.isNotEmpty && amount > 0) {
                      Navigator.pop(context, {
                        'name': name,
                        'amount': amount,
                        'iconCodePoint': _selectedIcon.codePoint,
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Lưu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
