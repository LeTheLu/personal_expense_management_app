import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/date_utils.dart';
import 'package:du_an/features/suggestion/domain/smart_parse_result.dart';

class SmartParseChips extends StatelessWidget {
  final SmartParseResultV2 result;
  final VoidCallback? onTapFund;
  final VoidCallback? onConfirm;

  const SmartParseChips({super.key, required this.result, this.onTapFund, this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: result.isComplete ? AppColors.income.withValues(alpha: 0.05) : AppColors.warning.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: result.isComplete ? AppColors.income.withValues(alpha: 0.3) : AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Action chip
              _actionChip(),
              const Icon(Icons.arrow_forward, size: 14, color: AppColors.textSecondary),
              // Fund chip
              _fundChip(),
              // Source chip
              if (result.sourceFundName != null) ...[
                Text('từ', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                _sourceChip(),
              ],
              // Amount chip
              if (result.amount != null) _amountChip(),
              // Secondary amount (hạn mức)
              if (result.secondaryAmount != null) ...[
                Text('hạn mức', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(AppDateUtils.formatCurrency(result.secondaryAmount!), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning)),
                ),
              ],
              // Due day
              if (result.dueDay != null) ...[
                Text('ngày ${result.dueDay}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ],
          ),
          // Note
          if (result.note != null && result.note!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.note, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    result.note!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionChip() {
    final label = result.actionLabel;
    final color = switch (result.action) {
      SmartAction.addToFund => AppColors.income,
      SmartAction.expense => AppColors.expense,
      SmartAction.createFund => AppColors.secondary,
      SmartAction.createBudget => AppColors.primary,
      SmartAction.createSaving => AppColors.secondary,
      SmartAction.createFixedExpense => AppColors.warning,
      SmartAction.ambiguous => AppColors.warning,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _fundChip() {
    if (result.fundName == null) return const SizedBox.shrink();

    final exists = result.fundExists;
    return GestureDetector(
      onTap: exists ? null : onTapFund,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: exists ? AppColors.primary.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: exists ? null : Border.all(color: AppColors.warning.withValues(alpha: 0.5), style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!exists) ...[
              const Text('Khác ', style: TextStyle(fontSize: 11, color: AppColors.warning)),
            ],
            Text(
              result.fundName!,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: exists ? AppColors.primary : AppColors.warning),
            ),
            if (!exists) ...[
              const SizedBox(width: 4),
              const Icon(Icons.touch_app, size: 12, color: AppColors.warning),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sourceChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.income.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        result.sourceFundName ?? '',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.income),
      ),
    );
  }

  Widget _amountChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        AppDateUtils.formatCurrency(result.amount!),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
