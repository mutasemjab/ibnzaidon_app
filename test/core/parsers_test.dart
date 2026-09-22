import 'package:flutter_test/flutter_test.dart';
import 'package:ibnzaidon/core/utils/formatters.dart';
import 'package:ibnzaidon/core/utils/parsers.dart';

void main() {
  group('parseDouble', () {
    test('accepts numbers and numeric strings', () {
      expect(parseDouble(12), 12.0);
      expect(parseDouble(12.5), 12.5);
      expect(parseDouble('12.50'), 12.5);
      expect(parseDouble(' 3 '), 3.0);
    });

    test('falls back on null / garbage', () {
      expect(parseDouble(null), 0);
      expect(parseDouble('abc', fallback: 7), 7);
      expect(tryParseDouble(<String>[]), isNull);
    });
  });

  group('parseInt', () {
    test('accepts ints, doubles and strings', () {
      expect(parseInt(4), 4);
      expect(parseInt(4.9), 4);
      expect(parseInt('15'), 15);
      expect(parseInt('15.0'), 15);
      expect(parseInt(null), 0);
    });
  });

  group('parseBool', () {
    test('accepts true/false and 1/0 in every form', () {
      expect(parseBool(true), isTrue);
      expect(parseBool(1), isTrue);
      expect(parseBool('1'), isTrue);
      expect(parseBool('true'), isTrue);
      expect(parseBool(false), isFalse);
      expect(parseBool(0), isFalse);
      expect(parseBool('0'), isFalse);
      expect(parseBool(null), isFalse);
      expect(parseBool(null, fallback: true), isTrue);
    });
  });

  group('tryParseDate', () {
    test('parses Y-m-d and Y-m-d H:i', () {
      expect(tryParseDate('2025-03-04'), DateTime(2025, 3, 4));
      expect(tryParseDate('2025-03-04 09:30'), DateTime(2025, 3, 4, 9, 30));
      expect(tryParseDate('nope'), isNull);
      expect(tryParseDate(5), isNull);
    });
  });

  group('mapList', () {
    test('skips malformed rows instead of throwing', () {
      final result = mapList<int>(
        [
          {'id': 1},
          'garbage',
          {'id': 'x'},
          {'id': 3},
        ],
        (json) => (json['id'] as int?) ?? (throw const FormatException()),
      );
      expect(result, [1, 3]);
    });
  });

  group('normalizeProgress', () {
    test('course detail progress is already 0..1', () {
      expect(normalizeProgress(0.4, isPercentage: false), 0.4);
    });

    test('my-courses progress_percentage is 0..100', () {
      expect(normalizeProgress(40, isPercentage: true), 0.4);
      expect(normalizeProgress('75', isPercentage: true), 0.75);
    });

    test('is clamped', () {
      expect(normalizeProgress(140, isPercentage: true), 1);
      expect(normalizeProgress(-3, isPercentage: false), 0);
    });
  });

  group('AppFormatters', () {
    test('currency uses JOD in English and د.أ in Arabic with 2 decimals', () {
      expect(AppFormatters.currency(12.5, 'en'), 'JOD 12.50');
      expect(AppFormatters.currency(12.5, 'ar'), '12.50 د.أ');
    });

    test('keeps Western digits in Arabic', () {
      expect(AppFormatters.number(1234), '1,234');
    });

    test('clock formats mm:ss and h:mm:ss', () {
      expect(AppFormatters.clock(const Duration(seconds: 65)), '01:05');
      expect(
        AppFormatters.clock(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '1:02:03',
      );
      expect(AppFormatters.clock(const Duration(seconds: -5)), '00:00');
    });
  });
}
