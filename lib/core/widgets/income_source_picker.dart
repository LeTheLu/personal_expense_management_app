import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/date_utils.dart';
import 'package:du_an/features/home/domain/entities/income_source.dart';

/// Returns the selected IncomeSource id
/// Default: auto-select the source with highest remaining balance
class IncomeSourcePicker extends StatelessWidget {
  final List<IncomeSource> sources;
  final double amount;
  final String title;

  const IncomeSourcePicker({
    super.key,
    required this.sources,
    required this.amount,
    this.title = 'Chọn nguồn tiền trừ',
  });

  /// Auto-select: pick source with highest remaining that can afford
  String? get _autoSourceId {
    final affordable = sources.where((s) => s.remainingAmount >= amount).toList();
    if (affordable.isEmpty) return null;
    affordable.sort((a, b) => b.remainingAmount.compareTo(a.remainingAmount));
    return affordable.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final autoId = _autoSourceId;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'Số tiền: ${AppDateUtils.formatCurrency(amount)}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),

            // Auto option (default)
            if (autoId != null) ...[
              GestureDetector(
                onTap: () => Navigator.pop(context, autoId),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tự động', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary)),
                            Text(
                              'Trừ từ nguồn có số dư cao nhất',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('Hoặc chọn nguồn cụ thể:', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ),
            ],

            // Individual sources
            ...sources.map((source) {
              final canAfford = source.remainingAmount >= amount;
              return GestureDetector(
                onTap: canAfford ? () => Navigator.pop(context, source.id) : null,
                child: Opacity(
                  opacity: canAfford ? 1.0 : 0.5,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: canAfford ? AppColors.income.withValues(alpha: 0.3) : Colors.grey.shade200),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.income.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Icon(source.icon, color: canAfford ? AppColors.income : Colors.grey, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(source.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: source.progress,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    source.isOverSpent ? AppColors.expense : AppColors.income,
                                  ),
                                  minHeight: 4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                canAfford
                                    ? 'Còn: ${AppDateUtils.formatCurrency(source.remainingAmount)}'
                                    : 'Không đủ số dư',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: canAfford ? AppColors.textSecondary : AppColors.expense,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppDateUtils.formatCurrency(source.remainingAmount > 0 ? source.remainingAmount : 0),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: canAfford ? AppColors.income : Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            if (autoId == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Không có nguồn nào đủ số dư để trừ ${AppDateUtils.formatCurrency(amount)}',
                  style: const TextStyle(color: AppColors.expense, fontSize: 12),
                ),
              ),

            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
