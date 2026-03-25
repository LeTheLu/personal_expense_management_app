import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/currency_input_formatter.dart';
import 'package:du_an/core/utils/date_utils.dart';
import 'package:du_an/di/injection.dart';
import 'package:du_an/features/saving/domain/entities/saving.dart';
import 'package:du_an/features/saving/domain/entities/saving_history.dart';
import 'package:du_an/features/saving/data/repositories/saving_repository.dart';
import 'package:du_an/features/saving/presentation/widgets/edit_saving_dialog.dart';
import 'package:du_an/features/home/data/repositories/income_source_repository.dart';
import 'package:du_an/core/widgets/income_source_picker.dart';
import 'package:du_an/core/widgets/rich_history_item.dart';

class SavingDetailPage extends StatefulWidget {
  final String savingId;

  const SavingDetailPage({super.key, required this.savingId});

  @override
  State<SavingDetailPage> createState() => _SavingDetailPageState();
}

class _SavingDetailPageState extends State<SavingDetailPage> {
  final _repo = getIt<SavingRepository>();
  final _incomeRepo = getIt<IncomeSourceRepository>();
  Saving? _saving;
  List<SavingHistoryEntry> _history = [];
  bool _deleted = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _saving = _repo.getById(widget.savingId);
      _history = _repo.getHistory(widget.savingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_deleted || _saving == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tích lũy')),
        body: const Center(child: Text('Mục tiêu đã bị xóa')),
      );
    }

    final saving = _saving!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết tích lũy'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _onEdit(saving)),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _onDelete(saving)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onAddAmount(saving),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add),
        label: const Text('Thêm tiền'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary.withValues(alpha: 0.1), AppColors.secondary.withValues(alpha: 0.05)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(saving.icon, color: AppColors.secondary, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(saving.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // Progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppDateUtils.formatCurrency(saving.currentAmount),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.secondary),
                      ),
                      Text(
                        ' / ${AppDateUtils.formatCurrency(saving.targetAmount)}',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: saving.progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        saving.isCompleted ? AppColors.income : AppColors.secondary,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${(saving.progress * 100).toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                      Text('Còn thiếu: ${AppDateUtils.formatCurrency(saving.remainingAmount > 0 ? saving.remainingAmount : 0)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Ngày tạo: ${AppDateUtils.formatDate(saving.createdAt)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  if (saving.isCompleted) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.income.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Đã hoàn thành!', style: TextStyle(color: AppColors.income, fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ),

            // History
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.history, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text('Lịch sử (${_history.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            if (_history.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('Chưa có lịch sử', style: TextStyle(color: Colors.grey.shade500, fontSize: 13))),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final entry = _history[index];
                  return RichHistoryItem(
                    action: entry.action,
                    description: entry.description,
                    oldAmount: entry.oldAmount,
                    newAmount: entry.newAmount,
                    date: entry.date,
                    isFirst: index == 0,
                    isLast: index == _history.length - 1,
                  );
                },
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _onEdit(Saving saving) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => EditSavingDialog(saving: saving),
    );
    if (result != null) {
      final updated = Saving(
        id: saving.id,
        name: result['name'] as String,
        currentAmount: result['currentAmount'] as double,
        targetAmount: result['targetAmount'] as double,
        createdAt: saving.createdAt,
        iconCodePoint: result['iconCodePoint'] as int,
      );
      await _repo.update(updated);
      _loadData();
    }
  }

  void _onAddAmount(Saving saving) async {
    // Step 1: Enter amount
    double? amount;
    await showDialog(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Thêm tiền tích lũy'),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyInputFormatter()],
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Số tiền thêm',
              suffixText: 'VND',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                final val = CurrencyInputFormatter.parse(ctrl.text);
                if (val > 0) {
                  amount = val;
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white),
              child: const Text('Tiếp'),
            ),
          ],
        );
      },
    );
    if (amount == null || !mounted) return;
    final amountVal = amount!;

    // Step 2: Pick income source
    final sources = _incomeRepo.getAll();
    if (sources.isEmpty) {
      // No income sources, just add directly
      await _repo.addAmount(saving.id, amountVal);
      _loadData();
      return;
    }

    final sourceId = await showDialog<String>(
      context: context,
      builder: (_) => IncomeSourcePicker(
        sources: sources,
        amount: amountVal,
        title: 'Trừ tiền từ nguồn nào?',
      ),
    );

    if (!mounted) return;

    await _repo.addAmount(saving.id, amountVal);
    if (sourceId != null) {
      await _incomeRepo.deductAmount(
        sourceId,
        amountVal,
        description: 'Tích lũy "${saving.name}" +${AppDateUtils.formatCurrency(amountVal)}',
      );
    }
    _loadData();
  }

  void _onDelete(Saving saving) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa mục tiêu'),
        content: Text('Bạn có chắc muốn xóa "${saving.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _repo.delete(saving.id);
      setState(() => _deleted = true);
      if (mounted) Navigator.pop(context, true);
    }
  }
}
