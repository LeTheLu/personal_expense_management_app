import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';

class SmartTagInput extends StatefulWidget {
  final List<Map<String, dynamic>> suggestions;
  final bool isComplete;
  final ValueChanged<String> onTextChanged;

  const SmartTagInput({
    super.key,
    required this.suggestions,
    required this.isComplete,
    required this.onTextChanged,
  });

  @override
  State<SmartTagInput> createState() => SmartTagInputState();
}

class SmartTagInputState extends State<SmartTagInput> {
  final ctrl = TextEditingController();

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input
        TextField(
          controller: ctrl,
          onChanged: widget.onTextChanged,
          decoration: InputDecoration(
            hintText: 'VD: "ăn sáng 30k" hoặc "tạo quỹ ăn uống 5tr"',
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            prefixIcon: const Icon(Icons.flash_on, color: AppColors.warning, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            suffixIcon: widget.isComplete
                ? const Icon(Icons.check_circle, color: AppColors.income)
                : ctrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 18, color: Colors.grey.shade500),
                        onPressed: () {
                          ctrl.clear();
                          widget.onTextChanged('');
                        },
                      )
                    : null,
          ),
          style: const TextStyle(fontSize: 14),
        ),
        // Suggestions - chữ nghiêng nhỏ
        if (widget.suggestions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: widget.suggestions.map((s) {
                final color = Color(s['color'] as int);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    final label = s['label'] as String;
                    // Xóa từ cuối đang gõ (phần chưa hoàn chỉnh) rồi nối gợi ý
                    final current = ctrl.text.trimRight();
                    final words = current.split(RegExp(r'\s+'));
                    // Bỏ từ cuối nếu nó là phần đầu của label (user đang gõ dở)
                    if (words.isNotEmpty) {
                      final lastWord = words.last.toLowerCase();
                      final labelLower = label.toLowerCase();
                      if (lastWord.isNotEmpty && (labelLower.startsWith(lastWord) || lastWord.startsWith(labelLower))) {
                        words.removeLast();
                      }
                    }
                    final base = words.join(' ').trimRight();
                    final newText = base.isEmpty ? '$label ' : '$base $label ';
                    ctrl.text = newText;
                    ctrl.selection = TextSelection.collapsed(offset: newText.length);
                    widget.onTextChanged(newText);
                  },
                  child: Text(
                    s['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: color,
                      decoration: TextDecoration.underline,
                      decorationColor: color.withValues(alpha: 0.3),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
