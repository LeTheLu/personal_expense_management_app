import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/currency_input_formatter.dart';
import 'package:du_an/core/widgets/icon_picker.dart';
import 'package:du_an/core/services/icon_registry.dart';
import 'package:du_an/di/injection.dart';
import 'package:du_an/features/saving/domain/entities/saving.dart';

class EditSavingDialog extends StatefulWidget {
  final Saving saving;

  const EditSavingDialog({super.key, required this.saving});

  @override
  State<EditSavingDialog> createState() => _EditSavingDialogState();
}

class _EditSavingDialogState extends State<EditSavingDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _currentCtrl;
  late final TextEditingController _targetCtrl;
  late IconData _selectedIcon;

  static const _icons = [
    Icons.savings, Icons.flight, Icons.directions_car, Icons.home,
    Icons.school, Icons.laptop, Icons.phone_android, Icons.beach_access,
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.saving.name);
    _currentCtrl = TextEditingController(text: widget.saving.currentAmount.round().toString());
    _targetCtrl = TextEditingController(text: widget.saving.targetAmount.round().toString());
    _selectedIcon = widget.saving.icon;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _currentCtrl.dispose();
    _targetCtrl.dispose();
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
              const Text('Sửa mục tiêu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Tên mục tiêu',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _currentCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                decoration: InputDecoration(
                  labelText: 'Số tiền hiện tại',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  suffixText: 'VND',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _targetCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                decoration: InputDecoration(
                  labelText: 'Mục tiêu',
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
                      final current = CurrencyInputFormatter.parse(_currentCtrl.text);
                      final target = CurrencyInputFormatter.parse(_targetCtrl.text);
                      if (name.isNotEmpty && target > 0) {
                        Navigator.pop(context, {
                          'name': name,
                          'currentAmount': current,
                          'targetAmount': target,
                          'iconCodePoint': _selectedIcon.codePoint,
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
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
      ),
    );
  }
}
