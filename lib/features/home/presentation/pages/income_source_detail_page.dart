import 'package:flutter/material.dart';
import 'package:du_an/core/constants/app_colors.dart';
import 'package:du_an/core/utils/date_utils.dart';
import 'package:du_an/di/injection.dart';
import 'package:du_an/features/home/domain/entities/income_source.dart';
import 'package:du_an/features/home/domain/entities/income_history.dart';
import 'package:du_an/features/home/data/repositories/income_source_repository.dart';
import 'package:du_an/features/home/presentation/widgets/edit_income_dialog.dart';
import 'package:du_an/core/widgets/rich_history_item.dart';

class IncomeSourceDetailPage extends StatefulWidget {
  final String incomeSourceId;

  const IncomeSourceDetailPage({super.key, required this.incomeSourceId});

  @override
  State<IncomeSourceDetailPage> createState() => _IncomeSourceDetailPageState();
}

class _IncomeSourceDetailPageState extends State<IncomeSourceDetailPage> {
  final _repo = getIt<IncomeSourceRepository>();
  IncomeSource? _source;
  List<IncomeHistoryEntry> _history = [];
  bool _deleted = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _source = _repo.getById(widget.incomeSourceId);
      _history = _repo.getHistory(widget.incomeSourceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_deleted || _source == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nguồn thu')),
        body: const Center(child: Text('Nguồn thu đã bị xóa')),
      );
    }

    final source = _source!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết nguồn thu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _onEdit(source),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _onDelete(source),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.income.withValues(alpha: 0.1), AppColors.income.withValues(alpha: 0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.income.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.income.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      IconData(source.iconCodePoint, fontFamily: 'MaterialIcons'),
                      color: AppColors.income,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(source.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    AppDateUtils.formatCurrency(source.amount),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.income),
                  ),
                  if (source.spentAmount > 0) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: source.progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          source.isOverSpent ? AppColors.expense : AppColors.income,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Đã dùng: ${AppDateUtils.formatCurrency(source.spentAmount)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        Text('Còn: ${AppDateUtils.formatCurrency(source.remainingAmount > 0 ? source.remainingAmount : 0)}',
                            style: TextStyle(fontSize: 12, color: source.isOverSpent ? AppColors.expense : AppColors.income, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Ngày tạo: ${AppDateUtils.formatDate(source.date)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // History section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.history, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Lịch sử chỉnh sửa (${_history.length})',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            if (_history.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text('Chưa có lịch sử', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                ),
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

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _onEdit(IncomeSource source) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => EditIncomeDialog(source: source),
    );
    if (result != null) {
      final updated = IncomeSource(
        id: source.id,
        name: result['name'] as String,
        amount: result['amount'] as double,
        date: source.date,
        iconCodePoint: result['iconCodePoint'] as int,
      );
      await _repo.update(updated);
      _loadData();
    }
  }

  void _onDelete(IncomeSource source) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa nguồn thu'),
        content: Text('Bạn có chắc muốn xóa "${source.name}"?'),
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
      await _repo.delete(source.id);
      setState(() => _deleted = true);
      if (mounted) Navigator.pop(context, true);
    }
  }
}
