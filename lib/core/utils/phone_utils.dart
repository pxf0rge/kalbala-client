/// Afghanistan phone number validation and formatting (+93).
abstract final class PhoneUtils {
  static const String countryCode = '+93';
  static const int nationalNumberLength = 9;

  /// Normalizes user input to E.164 format: +937XXXXXXXX
  ///
  /// Accepts:
  /// - `7XXXXXXXX` (9 digits)
  /// - `07XXXXXXXX` (local trunk prefix)
  /// - `937XXXXXXXX` / `+937XXXXXXXX`
  static String? normalizeAfghanPhone(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('93') && digits.length == 11) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0') && digits.length == 10) {
      digits = digits.substring(1);
    }

    // Common typo: 10 digits starting with 7 (extra digit) → keep first 9.
    if (digits.length == 10 && digits.startsWith('7')) {
      digits = digits.substring(0, 9);
    }

    if (digits.length != nationalNumberLength) {
      return null;
    }

    if (!digits.startsWith('7')) {
      return null;
    }

    return '$countryCode$digits';
  }

  /// Validates E.164 Afghanistan mobile format.
  static bool isValidAfghanPhone(String phone) {
    return RegExp(r'^\+937\d{8}$').hasMatch(phone);
  }

  /// Formats +93700123456 as 0700 123 456 for display.
  ///
  /// Wraps with LTR isolates so digit order stays correct inside RTL UI.
  static String formatForDisplay(String e164Phone) {
    final formatted = _formatNational(e164Phone);
    return '\u2066$formatted\u2069';
  }

  static String _formatNational(String e164Phone) {
    if (!e164Phone.startsWith(countryCode)) return e164Phone;
    final national = '0${e164Phone.substring(countryCode.length)}';
    if (national.length != 10) return e164Phone;
    return '${national.substring(0, 4)} ${national.substring(4, 7)} ${national.substring(7)}';
  }
}
