import 'package:intl/intl.dart';

class CurrencyFormatter {
  const CurrencyFormatter._();

  /// Formats an amount stored in smallest currency unit (cents for USD, yen for JPY).
  /// Automatically handles decimal conversion for currencies with subunits.
  static String format(int amount, {String currency = 'JPY'}) {
    final digits = _decimalDigitsForCurrency(currency);
    final displayAmount = digits > 0 ? amount / 100 : amount;
    final formatter = NumberFormat.currency(
      locale: _localeForCurrency(currency),
      symbol: _symbolForCurrency(currency),
      decimalDigits: digits,
    );
    return formatter.format(displayAmount);
  }

  /// Compact format for large amounts (e.g. $1.5K).
  static String formatCompact(int amount, {String currency = 'JPY'}) {
    final digits = _decimalDigitsForCurrency(currency);
    final displayAmount = digits > 0 ? amount / 100 : amount;
    final formatter = NumberFormat.compactCurrency(
      locale: _localeForCurrency(currency),
      symbol: _symbolForCurrency(currency),
      decimalDigits: digits,
    );
    return formatter.format(displayAmount);
  }

  /// Returns the number of decimal digits for a currency.
  /// JPY and KRW have no subunits (0 decimals).
  /// Most other currencies have 2 decimal places (cents, pence, etc.).
  static int _decimalDigitsForCurrency(String currency) {
    return switch (currency) {
      'JPY' || 'KRW' => 0,
      _ => 2,
    };
  }

  /// Returns the number of subunits per major unit.
  /// Used for converting between stored (smallest unit) and display amounts.
  static int subunitMultiplier(String currency) {
    return _decimalDigitsForCurrency(currency) > 0 ? 100 : 1;
  }

  static String _localeForCurrency(String currency) {
    return switch (currency) {
      'JPY' => 'ja_JP',
      'KRW' => 'ko_KR',
      'USD' => 'en_US',
      'GBP' => 'en_GB',
      'EUR' => 'de_DE',
      'AUD' => 'en_AU',
      'CAD' => 'en_CA',
      'NZD' => 'en_NZ',
      _ => 'en_US',
    };
  }

  static String _symbolForCurrency(String currency) {
    return switch (currency) {
      'JPY' => '¥',
      'KRW' => '₩',
      'USD' || 'AUD' || 'CAD' || 'NZD' => '\$',
      'GBP' => '£',
      'EUR' => '€',
      _ => currency,
    };
  }
}
