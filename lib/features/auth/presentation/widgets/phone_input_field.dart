import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/utils/phone_utils.dart';

/// Afghanistan mobile number field:
/// [flag +93] · digits (LTR, left-aligned)
class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    required this.controller,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.hairline.withValues(alpha: 0.95)),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          // National mobile is 9 digits (7XXXXXXXX). Leading 0 is optional
          // and handled by PhoneUtils when pasted as 07XXXXXXXX.
          LengthLimitingTextInputFormatter(10),
          _AfghanMobileInputFormatter(),
        ],
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: '700123456',
          hintStyle: TextStyle(
            color: AppColors.inkMuted.withValues(alpha: 0.55),
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          prefixIcon: const _AfghanCodeChip(),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 52,
          ),
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
          errorBorder: border.copyWith(
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: border.copyWith(
            borderSide: const BorderSide(color: AppColors.error, width: 1.4),
          ),
        ),
        onFieldSubmitted: onSubmitted,
        validator: (value) {
          final normalized = PhoneUtils.normalizeAfghanPhone(value ?? '');
          if (normalized == null) {
            return 'شماره باید ۹ رقم و با ۷ شروع شود (مثال: ۷۰۰۱۲۳۴۵۶)';
          }
          return null;
        },
      ),
    );
  }
}

/// Keeps Afghan mobile input to a valid shape while typing:
/// - `7XXXXXXXX` (9 digits), or
/// - `07XXXXXXXX` (10 digits with trunk 0).
class _AfghanMobileInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // With leading 0 → allow up to 10 (07XXXXXXXX).
    if (digits.startsWith('0')) {
      final clipped = digits.length > 10 ? digits.substring(0, 10) : digits;
      return TextEditingValue(
        text: clipped,
        selection: TextSelection.collapsed(offset: clipped.length),
      );
    }

    // Without leading 0 → national is exactly 9 (7XXXXXXXX).
    final clipped = digits.length > 9 ? digits.substring(0, 9) : digits;
    return TextEditingValue(
      text: clipped,
      selection: TextSelection.collapsed(offset: clipped.length),
    );
  }
}

class _AfghanCodeChip extends StatelessWidget {
  const _AfghanCodeChip();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _AfghanistanFlag(width: 26, height: 18),
          const SizedBox(width: 8),
          Text(
            PhoneUtils.countryCode,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: AppColors.inkMuted.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 8),
          Container(
            width: 1,
            height: 28,
            color: AppColors.hairline,
          ),
        ],
      ),
    );
  }
}

class _AfghanistanFlag extends StatelessWidget {
  const _AfghanistanFlag({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final stripe = width / 3;
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.hairline.withValues(alpha: 0.9),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: stripe,
                height: height,
                child: const ColoredBox(color: Color(0xFF000000)),
              ),
              SizedBox(
                width: stripe,
                height: height,
                child: const ColoredBox(color: Color(0xFFD32011)),
              ),
              SizedBox(
                width: width - stripe * 2,
                height: height,
                child: const ColoredBox(color: Color(0xFF007A36)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
