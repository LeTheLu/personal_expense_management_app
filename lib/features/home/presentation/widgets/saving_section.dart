import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/date_utils.dart';
import 'package:du_an/features/saving/domain/entities/saving.dart';

class SavingSection extends StatelessWidget {
  final List<Saving> savings;
  final double totalSaved;
  final VoidCallback? onAdd;
  final ValueChanged<String>? onTap;

  const SavingSection({super.key, required this.savings, this.totalSaved = 0, this.onAdd, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tích lũy', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Text(AppDateUtils.formatCurrency(totalSaved),
                      style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (savings.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.savings_outlined, color: Colors.grey.shade400, size: 32),
                  const SizedBox(height: 8),
                  Text('Chưa có mục tiêu tích lũy', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                ],
              ),
            )
          else
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: savings.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) => _savingCard(savings[index]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _savingCard(Saving saving) {
    return GestureDetector(
      onTap: () => onTap?.call(saving.id),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(saving.icon, color: AppColors.secondary, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(saving.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const Spacer(),
            Text(AppDateUtils.formatCurrency(saving.currentAmount),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('/ ${AppDateUtils.formatCurrency(saving.targetAmount)}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: saving.progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  saving.isCompleted ? AppColors.income : AppColors.secondary,
                ),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
