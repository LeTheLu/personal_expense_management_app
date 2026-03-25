import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/currency_input_formatter.dart';
import 'package:du_an/core/widgets/icon_picker.dart';
import 'package:du_an/core/services/icon_registry.dart';
import 'package:du_an/di/injection.dart';

class AddItemDialog extends StatefulWidget {
  final String title;
  final List<IconData> icons;
  final String amountLabel;

  const AddItemDialog({
    super.key,
    required this.title,
    required this.icons,
    this.amountLabel = 'Số tiền',
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  late IconData _selectedIcon;

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.icons.first;
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
            Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                labelText: widget.amountLabel,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                suffixText: 'VND',
              ),
            ),
            const SizedBox(height: 12),
            IconPicker(
              suggestedIcons: widget.icons,
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
                      Navigator.pop(context, {'name': name, 'icon': _selectedIcon, 'amount': amount});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Thêm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
