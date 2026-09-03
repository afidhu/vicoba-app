import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'sw_TZ',
    symbol: 'TZS ',
    decimalDigits: 0,
  );

  static String format(num? amount) {
    if (amount == null) return 'TZS 0';
    return _formatter.format(amount);
  }

  static String formatCompact(num? amount) {
    if (amount == null) return '0';
    if (amount >= 1000000) {
      return 'TZS ${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return 'TZS ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }
}

