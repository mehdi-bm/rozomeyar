/// Client-side validation mirroring the API contract, so a request that would
/// be rejected with 400 never leaves the device.
abstract final class AdsValidators {
  static const int descriptionMin = 5;
  static const int descriptionMax = 4000;
  static const int fullNameMin = 3;
  static const int fullNameMax = 160;
  static const int phoneDigitsMin = 7;
  static const int phoneDigitsMax = 20;
  static const int regionMin = 2;
  static const int regionMax = 100;
  static const int detailsMax = 4000;

  /// Persian (۰-۹) and Arabic-Indic (٠-٩) digits normalised to ASCII, so the
  /// API receives something it can parse whichever keyboard was used.
  static String normalizeDigits(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x06F0 && rune <= 0x06F9) {
        buffer.write(rune - 0x06F0); // Persian
      } else if (rune >= 0x0660 && rune <= 0x0669) {
        buffer.write(rune - 0x0660); // Arabic-Indic
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  /// Counts only digits — separators like +, spaces, dashes and parentheses
  /// are allowed but do not count toward the length.
  static int phoneDigitCount(String input) {
    var count = 0;
    for (final rune in normalizeDigits(input).runes) {
      if (rune >= 0x30 && rune <= 0x39) count++;
    }
    return count;
  }

  static bool isValidPhone(String input) {
    final digits = phoneDigitCount(input);
    return digits >= phoneDigitsMin && digits <= phoneDigitsMax;
  }

  static bool isValidDescription(String input) {
    final length = input.trim().characters;
    return length >= descriptionMin && length <= descriptionMax;
  }

  static bool isValidFullName(String input) {
    final length = input.trim().characters;
    return length >= fullNameMin && length <= fullNameMax;
  }

  static bool isValidRegion(String input) {
    final length = input.trim().characters;
    return length >= regionMin && length <= regionMax;
  }

  static bool isValidDetails(String input) =>
      input.trim().characters <= detailsMax;
}

extension on String {
  int get characters => runes.length;
}
