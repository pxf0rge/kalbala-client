import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/config/env.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_text_styles.dart';
import 'package:rahmani_project/core/utils/phone_utils.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/auth/presentation/widgets/otp_input_field.dart';
import 'package:rahmani_project/shared/widgets/rahmani_logo_mark.dart';

/// OTP verification after phone number submission — KalBala mock layout.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({required this.phone, super.key});

  final String phone;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isVerifying = false;
  bool _resendBusy = false;

  /// Fixed verification code used while SMS gateway is bypassed.
  static const _fixedCode = '123456';

  bool get _useFixedCode => Env.devLoginEnabled;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  String get _digits => _otpController.text.replaceAll(RegExp(r'\D'), '');

  Future<void> _verify() async {
    final entered = _digits;
    if (entered.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('کد تأیید باید ۶ رقم باشد')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    final bool success;
    if (_useFixedCode) {
      if (entered != _fixedCode) {
        if (mounted) {
          setState(() => _isVerifying = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('کد تأیید نامعتبر است')),
          );
        }
        return;
      }
      success = await ref.read(devLoginActionProvider.notifier).devLogin(
            phone: widget.phone,
          );
    } else {
      success = await ref.read(verifyOtpActionProvider.notifier).verify(
            phone: widget.phone,
            otp: entered,
          );
    }

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (!success) {
      final error = ref
          .read(
            _useFixedCode ? devLoginActionProvider : verifyOtpActionProvider,
          )
          .error;
      final message =
          error is String ? error : error?.toString() ?? 'کد تأیید نامعتبر است';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    context.go(RouteNames.home);
  }

  Future<void> _resend() async {
    if (_resendBusy) return;
    setState(() => _resendBusy = true);

    if (_useFixedCode) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _resendBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('کد جدید ارسال شد')),
      );
      return;
    }

    final national = widget.phone.startsWith(PhoneUtils.countryCode)
        ? '0${widget.phone.substring(PhoneUtils.countryCode.length)}'
        : widget.phone;

    final success = await ref.read(sendOtpActionProvider.notifier).send(national);
    if (!mounted) return;
    setState(() => _resendBusy = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'کد جدید ارسال شد' : 'ارسال مجدد ناموفق بود'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayPhone = PhoneUtils.formatForDisplay(widget.phone);
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final topInset = media.padding.top;
    final bottomInset = media.padding.bottom;
    const overlap = 22.0;
    final heroHeight = media.size.height * 0.36 + topInset * 0.15;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        // Keep layout fixed; keyboard overlays content.
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: heroHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF0E5C48),
                          AppColors.primary,
                          Color(0xFF06382C),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -40,
                    right: -60,
                    child: _Blob(
                      size: 200,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    left: -50,
                    child: _Blob(
                      size: 160,
                      color: const Color(0xFF127A62).withValues(alpha: 0.35),
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                      child: Column(
                        children: [
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Material(
                              color: Colors.white,
                              shape: const CircleBorder(),
                              elevation: 0,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => context.pop(),
                                child: const SizedBox(
                                  width: 42,
                                  height: 42,
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Image.asset(
                                      'assets/branding/otp_hero.png',
                                      height: 150,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const KalBalaLogoMark(
                                          size: 44,
                                          useBrandAsset: true,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          AppConstants.appName,
                                          style: AppTextStyles.brandMark.copyWith(
                                            color: Colors.white,
                                            fontSize: 28,
                                            height: 1.05,
                                          ),
                                        ),
                                        Text(
                                          AppConstants.appNameEn,
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                            color: Colors.white70,
                                            letterSpacing: 1.1,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'ورود به بازار آنلاین فروشگاه‌های افغانستان',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: Colors.white
                                                .withValues(alpha: 0.82),
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: heroHeight - overlap,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      28,
                      24,
                      12 + bottomInset * 0.15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE6F4EF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      color: AppColors.primary,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'کد تأیید را وارد کنید',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text.rich(
                                  TextSpan(
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.inkMuted,
                                      height: 1.55,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'کد ۶ رقمی ارسال شده به ',
                                      ),
                                      TextSpan(
                                        text: displayPhone,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w800,
                                          fontFeatures: [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                      const TextSpan(text: ' را وارد کنید.'),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                OtpInputField(
                                  controller: _otpController,
                                  onCompleted: (_) => _verify(),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'کد را دریافت نکردید؟',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: AppColors.inkMuted,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _resendBusy ? null : _resend,
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: _resendBusy
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              'ارسال مجدد',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 56,
                          child: FilledButton(
                            onPressed: _isVerifying ? null : _verify,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  AppColors.primary.withValues(alpha: 0.55),
                              shape: const StadiumBorder(),
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: _isVerifying
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.arrow_back_rounded,
                                          size: 22,
                                          color: Colors.white
                                              .withValues(alpha: 0.95),
                                        ),
                                        const Expanded(
                                          child: Text(
                                            'تأیید و ادامه',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 22),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.42),
      ),
    );
  }
}
