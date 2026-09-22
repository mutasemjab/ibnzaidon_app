import 'package:intl/intl.dart';

/// Locale-aware formatting that keeps Western digits in Arabic (matches the
/// website) and renders Jordanian Dinar per locale.
abstract final class AppFormatters {
  static const _currencyCodeEn = 'JOD';
  static const _currencySymbolAr = 'د.أ';
  static const _priceDecimals = 2;

  static String currency(double amount, String languageCode) {
    final number = NumberFormat.decimalPatternDigits(
      locale: 'en',
      decimalDigits: _priceDecimals,
    ).format(amount);
    return languageCode == 'ar'
        ? '$number $_currencySymbolAr'
        : '$_currencyCodeEn $number';
  }

  static String number(num value) =>
      NumberFormat.decimalPattern('en').format(value);

  static String compactNumber(num value) =>
      NumberFormat.compact(locale: 'en').format(value);

  static String date(DateTime date, String languageCode) =>
      DateFormat.yMMMd(languageCode).format(date);

  static String dateTime(DateTime date, String languageCode) =>
      DateFormat.yMMMd(languageCode).add_jm().format(date);

  static String clock(Duration duration) {
    final totalSeconds = duration.inSeconds < 0 ? 0 : duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$mm:$ss' : '$mm:$ss';
  }

  static String percent(double fraction) =>
      '${(fraction.clamp(0, 1) * 100).round()}%';
}
