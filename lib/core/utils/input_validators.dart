/// Shared input validation helpers for security-sensitive user input.
abstract final class InputValidators {
  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  /// Validates UUID v4 format (case-insensitive).
  static bool isValidUuid(String? value) {
    if (value == null || value.isEmpty) return false;
    return _uuidPattern.hasMatch(value.trim());
  }

  /// Trims and enforces non-empty required text.
  static String? validateRequiredText(String? value, {String? fieldLabel}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return fieldLabel != null ? '$fieldLabel الزامی است.' : 'این فیلد الزامی است.';
    }
    return null;
  }

  /// Enforces min/max length after trim.
  static String? validateTextLength(
    String? value, {
    int min = 1,
    int max = 500,
    String? fieldLabel,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.length < min) {
      return fieldLabel != null
          ? '$fieldLabel باید حداقل $min کاراکتر باشد.'
          : 'حداقل $min کاراکتر وارد کنید.';
    }
    if (trimmed.length > max) {
      return fieldLabel != null
          ? '$fieldLabel نباید بیشتر از $max کاراکتر باشد.'
          : 'حداکثر $max کاراکتر مجاز است.';
    }
    return null;
  }

  /// Validates positive monetary amounts (AFN).
  static String? validatePositiveAmount(
    String? value, {
    double min = 0.01,
    double max = 999999999,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'مبلغ الزامی است.';
    }

    final normalized = value.trim().replaceAll(',', '');
    final amount = double.tryParse(normalized);
    if (amount == null) {
      return 'مبلغ معتبر نیست.';
    }
    if (amount < min) {
      return 'مبلغ باید بیشتر از صفر باشد.';
    }
    if (amount > max) {
      return 'مبلغ بیش از حد مجاز است.';
    }
    return null;
  }

  /// Sanitizes user text: trim + enforce max length.
  static String sanitizeUserText(String value, {int maxLength = 2000}) {
    final trimmed = value.trim();
    if (trimmed.length <= maxLength) return trimmed;
    return trimmed.substring(0, maxLength);
  }

  /// Rejects strings containing obvious script injection patterns.
  static String? validateNoScriptInjection(String? value) {
    if (value == null) return null;
    final lower = value.toLowerCase();
    if (lower.contains('<script') ||
        lower.contains('javascript:') ||
        lower.contains('onerror=')) {
      return 'متن وارد شده معتبر نیست.';
    }
    return null;
  }
}
