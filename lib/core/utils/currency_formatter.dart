import 'package:intl/intl.dart';

class CurrencyFormatter {
  const CurrencyFormatter._();

  static String format(int amount, {String currency = 'JPY'}) {
    final formatter = NumberFormat.currency(
      locale: _localeForCurrency(currency),
      symbol: _symbolForCurrency(currency),
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatCompact(int amount, {String currency = 'JPY'}) {
    final formatter = NumberFormat.compactCurrency(
      locale: _localeForCurrency(currency),
      symbol: _symbolForCurrency(currency),
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String _localeForCurrency(String currency) {
    return switch (currency) {
      'JPY' => 'ja_JP',
      'KRW' => 'ko_KR',
      'USD' => 'en_US',
      _ => 'en_US',
    };
  }

  static String _symbolForCurrency(String currency) {
    return switch (currency) {
      'JPY' => '¥',
      'KRW' => '₩',
      'USD' => '\$',
      _ => currency,
    };
  }
}
