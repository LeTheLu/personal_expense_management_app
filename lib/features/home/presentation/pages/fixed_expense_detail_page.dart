import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/date_utils.dart';
import 'package:du_an/core/utils/currency_input_formatter.dart';
import 'package:du_an/core/widgets/icon_picker.dart';
import 'package:du_an/core/services/icon_registry.dart';
import 'package:du_an/di/injection.dart';
import 'package:du_an/features/home/domain/entities/fixed_expense.dart';
import 'package:du_an/features/home/data/repositories/fixed_expense_repository.dart';

class FixedExpenseDetailPage extends StatefulWidget {
  final String fixedExpenseId;

  const FixedExpenseDetailPage({super.key, required this.fixedExpenseId});

  @override
  State<FixedExpenseDetailPage> createState() => _FixedExpenseDetailPageState();
}

class _FixedExpenseDetailPageState extends State<FixedExpenseDetailPage> {
  final _repo = getIt<FixedExpenseRepository>();
  FixedExpense? _item;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _item = _repo.getAll().where((f) => f.id == widget.fixedExpenseId).firstOrNull;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi phí cố định')),
        body: const Center(child: Text('Đã bị xóa')),
      );
    }

    final item = _item!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết chi phí cố định'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _onEdit(item)),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _onDelete(item)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.warning.withValues(alpha: 0.1), AppColors.warning.withValues(alpha: 0.05)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                    child: Icon(item.icon, color: AppColors.warning, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(item.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(AppDateUtils.formatCurrency(item.amount),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.warning)),
                  const SizedBox(height: 12),
                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: (item.isPaid ? AppColors.income : AppColors.expense).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.isPaid ? 'Đã thanh toán' : 'Chưa thanh toán',
                      style: TextStyle(color: item.isPaid ? AppColors.income : AppColors.expense, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Info rows
                  _infoRow('Ngày thanh toán', 'Ngày ${item.dueDay} hàng tháng'),
                  _infoRow('Lặp lại', item.isRecurring ? 'Hàng tháng' : 'Một lần'),
                  if (item.paidFrom != null) _infoRow('Nguồn thanh toán', item.paidFrom!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _onEdit(FixedExpense item) async {
    final nameCtrl = TextEditingController(text: item.name);
    final amountCtrl = TextEditingController(text: item.amount.round().toString());
    final dueDayCtrl = TextEditingController(text: item.dueDay.toString());
    var selectedIcon = item.icon;
    var isRecurring = item.isRecurring;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sửa chi phí cố định', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Tên', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
                  const SizedBox(height: 12),
                  TextField(controller: amountCtrl, keyboardType: TextInputType.number, inputFormatters: [CurrencyInputFormatter()],
                      decoration: InputDecoration(labelText: 'Số tiền', suffixText: 'VND', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
                  const SizedBox(height: 12),
                  TextField(controller: dueDayCtrl, keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Ngày thanh toán (1-31)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => setDialogState(() => isRecurring = !isRecurring),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isRecurring ? AppColors.primary.withValues(alpha: 0.08) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isRecurring ? AppColors.primary : Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(isRecurring ? Icons.check_box : Icons.check_box_outline_blank, size: 20, color: isRecurring ? AppColors.primary : Colors.grey),
                          const SizedBox(width: 8),
                          const Text('Lặp lại hàng tháng', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  IconPicker(
                    suggestedIcons: const [Icons.home, Icons.bolt, Icons.water_drop, Icons.wifi, Icons.phone, Icons.fitness_center, Icons.subscriptions, Icons.credit_card],
                    selectedIcon: selectedIcon,
                    usedIcons: getIt<IconRegistry>().getUsedIconCodePoints(),
                    onSelected: (icon) => setDialogState(() => selectedIcon = icon),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          final amount = CurrencyInputFormatter.parse(amountCtrl.text);
                          final dueDay = (int.tryParse(dueDayCtrl.text.trim()) ?? 1).clamp(1, 31);
                          if (name.isNotEmpty && amount > 0) {
                            Navigator.pop(ctx, {'name': name, 'amount': amount, 'dueDay': dueDay, 'isRecurring': isRecurring, 'iconCodePoint': selectedIcon.codePoint});
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text('Lưu'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (result != null) {
      final now = DateTime.now();
      final updated = FixedExpense(
        id: item.id,
        name: result['name'] as String,
        amount: result['amount'] as double,
        isPaid: item.isPaid,
        dueDate: DateTime(now.year, now.month, (result['dueDay'] as int).clamp(1, 31)),
        paidFrom: item.paidFrom,
        iconCodePoint: result['iconCodePoint'] as int,
        isRecurring: result['isRecurring'] as bool,
        dueDay: result['dueDay'] as int,
      );
      await _repo.update(updated);
      _loadData();
    }
  }

  void _onDelete(FixedExpense item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa chi phí cố định'),
        content: Text('Bạn có chắc muốn xóa "${item.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Xóa')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _repo.delete(item.id);
      if (mounted) Navigator.pop(context, true);
    }
  }
}
