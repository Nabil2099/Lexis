import 'package:intl/intl.dart';

class LexisDateUtils {
  const LexisDateUtils._();

  static String compact(DateTime value) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(value.year, value.month, value.day);
    if (date == today) return DateFormat('HH:mm').format(value);
    if (date.year == now.year) return DateFormat('MMM d').format(value);
    return DateFormat('MMM d, y').format(value);
  }

  static String verbose(DateTime value) =>
      DateFormat('MMM d, y HH:mm').format(value);
}
