import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MM/yyyy').format(date);
  }

  static String formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} VND';
  }
}
