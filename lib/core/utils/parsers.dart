// Tolerant parsers. The backend sends numbers as numbers *or* strings,
// booleans as true/false or 1/0, and dates as Y-m-d or Y-m-d H:i.

double? tryParseDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

double parseDouble(Object? value, {double fallback = 0}) =>
    tryParseDouble(value) ?? fallback;

int? tryParseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final trimmed = value.trim();
    return int.tryParse(trimmed) ?? double.tryParse(trimmed)?.toInt();
  }
  return null;
}

int parseInt(Object? value, {int fallback = 0}) =>
    tryParseInt(value) ?? fallback;

bool parseBool(Object? value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.trim().toLowerCase()) {
      case 'true' || '1' || 'yes':
        return true;
      case 'false' || '0' || 'no' || '':
        return false;
    }
  }
  return fallback;
}

String? tryParseString(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

String parseString(Object? value, {String fallback = ''}) =>
    tryParseString(value) ?? fallback;

DateTime? tryParseDate(Object? value) {
  if (value is! String) return null;
  final text = value.trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text.replaceFirst(' ', 'T'));
}

Map<String, dynamic>? asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, dynamic v) => MapEntry(key.toString(), v));
  }
  return null;
}

List<Object?> asList(Object? value) => value is List ? value : const [];

/// Maps every well-formed map item; malformed items are skipped so one bad
/// row never breaks a whole section.
List<T> mapList<T>(
  Object? value,
  T Function(Map<String, dynamic> json) parse,
) {
  final result = <T>[];
  for (final item in asList(value)) {
    final map = asMap(item);
    if (map == null) continue;
    try {
      result.add(parse(map));
    } on Object {
      continue;
    }
  }
  return result;
}

/// Progress is 0..1 in `GET courses/{id}` but 0..100 in `my-courses`.
double normalizeProgress(Object? raw, {required bool isPercentage}) {
  final value = parseDouble(raw);
  final normalized = isPercentage ? value / 100 : value;
  return normalized.clamp(0, 1);
}
