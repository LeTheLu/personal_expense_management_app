import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Format số tiền với dấu phân cách khi nhập: 3000000 → 3,000,000
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'vi_VN');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    // Chỉ giữ chữ số
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));

    final number = int.tryParse(digits) ?? 0;
    final formatted = _formatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Parse formatted text back to double: "3,000,000" → 3000000.0
  static double parse(String text) {
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(digits) ?? 0;
  }
}
