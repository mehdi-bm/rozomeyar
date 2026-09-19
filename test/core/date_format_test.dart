import 'package:flutter_test/flutter_test.dart';
import 'package:resumeyar/core/utils/date_format.dart';
import 'package:resumeyar/domain/models/enums.dart';

void main() {
  // 2021-08-11 Gregorian is 1400-05-20 Jalali.
  final august2021 = DateTime(2021, 8, 11);

  group('Persian formatting', () {
    test('monthYear uses Jalali month names and Persian digits', () {
      expect(
        AppDateFormat.monthYear(august2021, ResumeLanguage.persian),
        'مرداد ۱۴۰۰',
      );
    });

    test('yearOnly converts to the Jalali year', () {
      expect(
        AppDateFormat.yearOnly(august2021, ResumeLanguage.persian),
        '۱۴۰۰',
      );
    });

    test('fullDate is zero-padded Jalali', () {
      expect(
        AppDateFormat.fullDate(august2021, ResumeLanguage.persian),
        '۱۴۰۰/۰۵/۲۰',
      );
    });
  });

  group('English formatting', () {
    test('monthYear uses Gregorian short month names', () {
      expect(
        AppDateFormat.monthYear(august2021, ResumeLanguage.english),
        'Aug 2021',
      );
    });

    test('fullDate is ISO-like', () {
      expect(
        AppDateFormat.fullDate(august2021, ResumeLanguage.english),
        '2021-08-11',
      );
    });
  });

  group('range', () {
    test('joins both bounds', () {
      expect(
        AppDateFormat.range(
          start: DateTime(2018, 4),
          end: DateTime(2021, 6),
          isCurrent: false,
          language: ResumeLanguage.english,
          presentLabel: 'Present',
        ),
        'Apr 2018 - Jun 2021',
      );
    });

    test('uses the present label when currently active', () {
      expect(
        AppDateFormat.range(
          start: august2021,
          end: DateTime(2030, 1),
          isCurrent: true,
          language: ResumeLanguage.persian,
          presentLabel: 'تاکنون',
        ),
        'مرداد ۱۴۰۰ - تاکنون',
      );
    });

    test('returns only the bound that exists', () {
      expect(
        AppDateFormat.range(
          start: august2021,
          end: null,
          isCurrent: false,
          language: ResumeLanguage.english,
          presentLabel: 'Present',
        ),
        'Aug 2021',
      );
    });

    test('returns an empty string when there is nothing to show', () {
      expect(
        AppDateFormat.range(
          start: null,
          end: null,
          isCurrent: false,
          language: ResumeLanguage.english,
          presentLabel: 'Present',
        ),
        '',
      );
    });
  });

  group('toPersianDigits', () {
    test('converts digits and leaves other characters alone', () {
      expect(AppDateFormat.toPersianDigits('1400/05'), '۱۴۰۰/۰۵');
      expect(AppDateFormat.toPersianDigits('A1-b2'), 'A۱-b۲');
      expect(AppDateFormat.toPersianDigits('مرداد'), 'مرداد');
    });
  });
}
