import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';

/// Six individual OTP digit boxes (matches KalBala OTP mock).
class OtpInputField extends StatefulWidget {
  const OtpInputField({
    required this.controller,
    this.onCompleted,
    this.autofocus = true,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;
  final bool autofocus;

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late final FocusNode _focusNode;

  String get _digits => widget.controller.text.replaceAll(RegExp(r'\D'), '');

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(() => setState(() {}));
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    final digits = _digits;
    if (digits.length > 6) {
      widget.controller.value = TextEditingValue(
        text: digits.substring(0, 6),
        selection: const TextSelection.collapsed(offset: 6),
      );
      return;
    }
    setState(() {});
    if (digits.length == 6) {
      widget.onCompleted?.call(digits);
    }
  }

  void _onChanged(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 6 ? digits.substring(0, 6) : digits;
    if (clipped != widget.controller.text) {
      widget.controller.value = TextEditingValue(
        text: clipped,
        selection: TextSelection.collapsed(offset: clipped.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final digits = _digits;
    final focused = _focusNode.hasFocus;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0,
            child: TextField(
              key: const Key('otp_input_field'),
              controller: widget.controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              keyboardType: TextInputType.number,
              showCursor: false,
              enableInteractiveSelection: false,
              style: const TextStyle(color: Colors.transparent, height: 0.01),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              onChanged: _onChanged,
            ),
          ),
          Directionality(
            textDirection: ui.TextDirection.ltr,
            child: LayoutBuilder(
              builder: (context, constraints) {
                const gap = 8.0;
                final boxWidth = ((constraints.maxWidth - gap * 5) / 6)
                    .clamp(40.0, 52.0);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < 6; i++) ...[
                      if (i > 0) const SizedBox(width: gap),
                      _OtpDigitBox(
                        width: boxWidth,
                        digit: i < digits.length ? digits[i] : '',
                        active: focused && digits.length == i,
                        filled: i < digits.length,
                        showCursor: focused && digits.length == i,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpDigitBox extends StatelessWidget {
  const _OtpDigitBox({
    required this.width,
    required this.digit,
    required this.active,
    required this.filled,
    required this.showCursor,
  });

  final double width;
  final String digit;
  final bool active;
  final bool filled;
  final bool showCursor;

  @override
  Widget build(BuildContext context) {
    final borderColor = active
        ? AppColors.primary
        : filled
            ? AppColors.primaryMid
            : const Color(0xFFE5EBE8);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: width,
      height: width * 1.15,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: active ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: active
                ? AppColors.primary.withValues(alpha: 0.14)
                : const Color(0x14000000),
            blurRadius: active ? 10 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: showCursor && digit.isEmpty
          ? Container(
              width: 2,
              height: width * 0.38,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(1),
              ),
            )
          : Text(
              digit,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    height: 1,
                  ),
            ),
    );
  }
}
