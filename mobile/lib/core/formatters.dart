import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Format price: `100000` → `"100,000 HUF"` (EN) or `"100 000 Ft"` (HU).
String formatPrice(double? price, String lang) {
  if (price == null) return ''; // Caller supplies "Price on request" via l10n
  if (lang.toLowerCase().startsWith('hu')) {
    final fmt = NumberFormat.decimalPattern('hu_HU');
    return '${fmt.format(price)} Ft';
  }
  final fmt = NumberFormat.decimalPattern('en_US');
  return '${fmt.format(price)} HUF';
}

/// Format large numbers: `1500` → `"1.5K"`.
String formatCompact(int value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
  return value.toString();
}

/// Relative time using [timeago] — register locales once in app bootstrap.
String timeAgoFormatted(DateTime date, String lang) {
  final locale = lang.toLowerCase().startsWith('hu') ? 'hu' : 'en';
  return timeago.format(date, locale: locale);
}
