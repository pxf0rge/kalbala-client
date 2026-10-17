import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/config/env.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/core/utils/phone_utils.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/auth/presentation/widgets/phone_input_field.dart';

/// Account recovery guidance for phone-only auth.
///
/// Recovery = sign in again with OTP on the same number.
/// Optionally checks blocked status via [get_account_recovery_hint].
class AccountRecoveryScreen extends ConsumerStatefulWidget {
  const AccountRecoveryScreen({super.key});

  @override
  ConsumerState<AccountRecoveryScreen> createState() =>
      _AccountRecoveryScreenState();
}

class _AccountRecoveryScreenState extends ConsumerState<AccountRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isBusy = false;
  String? _hintMessage;
  bool _blocked = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _checkAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = PhoneUtils.normalizeAfghanPhone(_phoneController.text);
    if (phone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('شماره موبایل معتبر نیست. مثال: 0700123456')),
      );
      return;
    }

    setState(() {
      _isBusy = true;
      _hintMessage = null;
      _blocked = false;
    });

    final result =
        await ref.read(authRepositoryProvider).getAccountRecoveryHint(phone);
    if (!mounted) return;

    final blocked = result.fold((_) => false, (hint) => hint.blocked);
    final message = result.fold(
      (failure) => failure.message,
      (hint) => hint.message,
    );

    if (blocked) {
      setState(() {
        _isBusy = false;
        _hintMessage = message;
        _blocked = true;
      });
      return;
    }

    // Dev mode: OTP screen handles bypass login without SMS.
    if (Env.devLoginEnabled) {
      setState(() {
        _isBusy = false;
        _hintMessage = message;
      });
      context.push(RouteNames.otpVerification, extra: phone);
      return;
    }

    final sent = await ref.read(sendOtpActionProvider.notifier).send(
          _phoneController.text,
        );
    if (!mounted) return;

    if (!sent) {
      final error = ref.read(sendOtpActionProvider).error;
      setState(() {
        _isBusy = false;
        _hintMessage =
            error is String ? error : error?.toString() ?? 'ارسال کد ناموفق بود';
      });
      return;
    }

    setState(() {
      _isBusy = false;
      _hintMessage = message;
    });
    context.push(RouteNames.otpVerification, extra: phone);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('بازیابی حساب')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ورود مجدد با همان شماره',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'حساب شما با شماره موبایل ساخته می‌شود. برای بازیابی، همان شماره‌ای که قبلاً ثبت کرده‌اید را وارد کنید و با کد تأیید وارد شوید.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PhoneInputField(
                  controller: _phoneController,
                  onSubmitted: (_) => _checkAndContinue(),
                ),
                if (_hintMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Material(
                    color: _blocked
                        ? Theme.of(context).colorScheme.errorContainer
                        : AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        _hintMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _blocked
                              ? Theme.of(context).colorScheme.onErrorContainer
                              : AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (!_blocked)
                  FilledButton(
                    onPressed: _isBusy ? null : _checkAndContinue,
                    child: _isBusy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('ادامه با کد تأیید'),
                  ),
                TextButton(
                  onPressed: () => context.go(RouteNames.login),
                  child: const Text('بازگشت به ورود'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}