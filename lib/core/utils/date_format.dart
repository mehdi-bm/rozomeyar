import 'package:shamsi_date/shamsi_date.dart';

import '../../domain/models/enums.dart';

const List<String> _gregorianMonths = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _persianDigits = <String>[
  '۰',
  '۱',
  '۲',
  '۳',
  '۴',
  '۵',
  '۶',
  '۷',
  '۸',
  '۹',
];

/// Arabic-Indic digits — visually different from the Persian set above for
/// four, five and six, so an Arabic resume must not reuse the Persian digits.
const List<String> _arabicDigits = <String>[
  '٠',
  '١',
  '٢',
  '٣',
  '٤',
  '٥',
  '٦',
  '٧',
  '٨',
  '٩',
];

const List<String> _arabicMonths = <String>[
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

/// Date rendering for resumes and app chrome.
///
/// Persian output uses the Jalali calendar and Persian digits; English output
/// uses the Gregorian calendar and Latin digits. Which one applies is decided by
/// the *resume* language, not the app language.
abstract final class AppDateFormat {
  static String toPersianDigits(String input) =>
      _convertDigits(input, _persianDigits);

  static String toArabicDigits(String input) =>
      _convertDigits(input, _arabicDigits);

  static String _convertDigits(String input, List<String> digits) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x30 && rune <= 0x39) {
        buffer.write(digits[rune - 0x30]);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  /// Applies the digit shapes the resume's language expects.
  static String localizeDigits(String input, ResumeLanguage language) =>
      switch (language) {
        ResumeLanguage.persian => toPersianDigits(input),
        ResumeLanguage.arabic => toArabicDigits(input),
        ResumeLanguage.english => input,
      };

  /// "مرداد ۱۴۰۰" / "أغسطس ٢٠٢١" / "Aug 2021"
  ///
  /// Only Persian resumes use the Jalali calendar; Arabic ones use Gregorian
  /// months with Arabic names, which is the convention for Arabic CVs.
  static String monthYear(DateTime date, ResumeLanguage language) {
    if (language == ResumeLanguage.persian) {
      final jalali = Jalali.fromDateTime(date);
      return toPersianDigits('${jalali.formatter.mN} ${jalali.year}');
    }
    if (language == ResumeLanguage.arabic) {
      return toArabicDigits('${_arabicMonths[date.month - 1]} ${date.year}');
    }
    return '${_gregorianMonths[date.month - 1]} ${date.year}';
  }

  /// "۱۴۰۰" / "٢٠٢١" / "2021"
  static String yearOnly(DateTime date, ResumeLanguage language) {
    if (language == ResumeLanguage.persian) {
      return toPersianDigits('${Jalali.fromDateTime(date).year}');
    }
    return localizeDigits('${date.year}', language);
  }

  /// "۱۴۰۰/۰۵/۲۰" / "٢٠٢١-٠٨-١١" / "2021-08-11"
  static String fullDate(DateTime date, ResumeLanguage language) {
    if (language == ResumeLanguage.persian) {
      final jalali = Jalali.fromDateTime(date);
      final month = jalali.month.toString().padLeft(2, '0');
      final day = jalali.day.toString().padLeft(2, '0');
      return toPersianDigits('${jalali.year}/$month/$day');
    }
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return localizeDigits('${date.year}-$month-$day', language);
  }

  /// "مرداد ۱۴۰۰ - تاکنون". Returns an empty string when neither bound is set,
  /// so templates can skip the line entirely.
  static String range({
    required DateTime? start,
    required DateTime? end,
    required bool isCurrent,
    required ResumeLanguage language,
    required String presentLabel,
  }) {
    final startLabel = start == null ? null : monthYear(start, language);
    final endLabel = isCurrent
        ? presentLabel
        : (end == null ? null : monthYear(end, language));

    if (startLabel == null && endLabel == null) return '';
    if (startLabel == null) return endLabel!;
    if (endLabel == null) return startLabel;
    return '$startLabel - $endLabel';
  }

  /// Short date for app chrome (e.g. "last edited"), following the app locale.
  static String uiDate(DateTime date, String localeCode) {
    if (localeCode == 'fa') {
      final jalali = Jalali.fromDateTime(date);
      final month = jalali.month.toString().padLeft(2, '0');
      final day = jalali.day.toString().padLeft(2, '0');
      return toPersianDigits('${jalali.year}/$month/$day');
    }
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
