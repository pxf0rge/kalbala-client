import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/core/utils/phone_utils.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/auth/presentation/widgets/otp_input_field.dart';
import 'package:rahmani_project/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:rahmani_project/features/profile/presentation/providers/profile_provider.dart';

/// Change phone number: enter new phone → OTP → confirm.
class ChangePhoneScreen extends ConsumerStatefulWidget {
  const ChangePhoneScreen({super.key});

  @override
  ConsumerState<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends ConsumerState<ChangePhoneScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _otpSent = false;
  String? _pendingPhone;
  bool _isBusy = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = PhoneUtils.normalizeAfghanPhone(_phoneController.text);
    if (phone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('شماره موبایل معتبر نیست. مثال: 0700123456')),
      );
      return;
    }

    setState(() => _isBusy = true);
    final success =
        await ref.read(requestPhoneChangeActionProvider.notifier).request(phone);
    if (!mounted) return;
    setState(() => _isBusy = false);

    if (!success) {
      final error = ref.read(requestPhoneChangeActionProvider).error;
      final message =
          error is String ? error : error?.toString() ?? 'ارسال کد ناموفق بود';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    setState(() {
      _otpSent = true;
      _pendingPhone = phone;
    });
  }

  Future<void> _confirm() async {
    final phone = _pendingPhone;
    if (phone == null) return;

    setState(() => _isBusy = true);
    final success = await ref.read(confirmPhoneChangeActionProvider.notifier).confirm(
          newPhone: phone,
          otp: _otpController.text,
        );
    if (!mounted) return;
    setState(() => _isBusy = false);

    if (!success) {
      final error = ref.read(confirmPhoneChangeActionProvider).error;
      final message =
          error is String ? error : error?.toString() ?? 'تأیید کد ناموفق بود';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    ref.invalidate(profileProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('شماره موبایل با موفقیت تغییر کرد')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPhone = ref.watch(profileProvider).valueOrNull?.phone;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('تغییر شماره موبایل')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (currentPhone != null && currentPhone.isNotEmpty) ...[
                  Text(
                    'شماره فعلی: ${PhoneUtils.formatForDisplay(currentPhone)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                Text(
                  _otpSent ? 'کد تأیید شماره جدید' : 'شماره موبایل جدید',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _otpSent
                      ? 'کد ارسال‌شده به ${PhoneUtils.formatForDisplay(_pendingPhone ?? '')} را وارد کنید.'
                      : 'شماره جدید فقط پس از تأیید با کد OTP فعال می‌شود.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (!_otpSent)
                  PhoneInputField(
                    controller: _phoneController,
                    onSubmitted: (_) => _requestOtp(),
                  )
                else ...[
                  OtpInputField(
                    controller: _otpController,
                    onCompleted: (_) => _confirm(),
                  ),
                  TextButton(
                    onPressed: _isBusy
                        ? null
                        : () => setState(() {
                              _otpSent = false;
                              _pendingPhone = null;
                              _otpController.clear();
                            }),
                    child: const Text('تغییر شماره واردشده'),
                  ),
                ],
                const Spacer(),
                FilledButton(
                  onPressed: _isBusy ? null : (_otpSent ? _confirm : _requestOtp),
                  child: _isBusy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_otpSent ? 'تأیید و ذخیره' : 'دریافت کد تأیید'),
                ),
                if (_otpSent) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isBusy ? null : _requestOtp,
                    child: const Text('ارسال مجدد کد'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}