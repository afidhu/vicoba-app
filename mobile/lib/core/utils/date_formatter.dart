import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _date = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTime = DateFormat('dd MMM yyyy, HH:mm');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

  static String format(DateTime? date) {
    if (date == null) return '-';
    return _date.format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '-';
    return _dateTime.format(date);
  }

  static String toIsoDateString(DateTime date) {
    return _isoDate.format(date);
  }

  static DateTime? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
}

