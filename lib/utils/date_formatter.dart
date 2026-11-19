import 'package:intl/intl.dart';

/// Format tanggal ISO 8601 ke format Indonesia yang mudah dibaca.
class DateFormatter {
  DateFormatter._();

  /// Format: "18 Nov 2026, 07:30"
  static String formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  /// Format panjang: "Senin, 18 November 2026 – 07:30"
  static String formatDateLong(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('EEEE, dd MMMM yyyy – HH:mm', 'id_ID').format(date);
    } catch (_) {
      return isoDate;
    }
  }
}
