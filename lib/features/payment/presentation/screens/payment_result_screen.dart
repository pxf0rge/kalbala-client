import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/features/order/presentation/providers/order_provider.dart';
import 'package:rahmani_project/features/payment/domain/entities/payment_entities.dart';
import 'package:rahmani_project/features/payment/domain/entities/payment_enums.dart';
import 'package:rahmani_project/features/payment/presentation/providers/payment_provider.dart';
import 'package:rahmani_project/features/payment/presentation/widgets/payment_status_indicator.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Payment result screen with status polling.
class PaymentResultScreen extends ConsumerStatefulWidget {
  const PaymentResultScreen({required this.orderId, super.key});

  final String orderId;

  @override
  ConsumerState<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends ConsumerState<PaymentResultScreen> {
  Timer? _pollTimer;
  PaymentStatus _status = PaymentStatus.processing;
  bool _isPolling = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final extra = GoRouterState.of(context).extra;
    if (extra is InitiatePaymentResultEntity) {
      if (extra.sandbox) {
        // Sandbox gateways have no real redirect — finalize as paid without
        // exposing simulate controls in the UI.
        await _finalizeSandboxSuccess(extra.paymentId);
      } else {
        _startPolling(extra.paymentId);
      }
      return;
    }

    final paymentIdFromQuery = GoRouterState.of(context).uri.queryParameters['paymentId'];
    if (paymentIdFromQuery != null && paymentIdFromQuery.isNotEmpty) {
      _startPolling(paymentIdFromQuery);
      return;
    }

    final order = await ref.read(orderDetailProvider(widget.orderId).future);
    if (!mounted) return;
    final paymentId = order?.payment?.paymentId;
    if (paymentId == null || paymentId.isEmpty) {
      setState(() => _isPolling = false);
      return;
    }
    _startPolling(paymentId);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling(String paymentId) {
    setState(() {
      _isPolling = true;
      _status = PaymentStatus.processing;
    });
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final result = await ref.read(getPaymentStatusProvider).call(paymentId);
      if (!mounted) return;

      result.fold((_) {}, (payment) {
        setState(() => _status = payment.status);
        if (payment.status.isTerminal) {
          _pollTimer?.cancel();
          setState(() => _isPolling = false);
          ref.invalidate(orderDetailProvider(widget.orderId));
          ref.invalidate(myOrdersProvider);
        }
      });
    });
  }

  Future<void> _finalizeSandboxSuccess(String paymentId) async {
    setState(() {
      _isPolling = true;
      _status = PaymentStatus.processing;
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final result = await ref.read(completeSandboxPaymentProvider).call(
          paymentId: paymentId,
          success: true,
        );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _status = PaymentStatus.failed;
          _isPolling = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (payment) {
        setState(() {
          _status = payment.status;
          _isPolling = false;
        });
        ref.invalidate(orderDetailProvider(widget.orderId));
        ref.invalidate(myOrdersProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = _status == PaymentStatus.completed;
    final isFailed = _status == PaymentStatus.failed;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('نتیجه پرداخت')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isPolling)
              const AppLoadingIndicator(message: 'در حال بررسی وضعیت پرداخت...')
            else ...[
              Icon(
                isSuccess
                    ? Icons.check_circle_outline
                    : isFailed
                        ? Icons.cancel_outlined
                        : Icons.hourglass_top,
                size: 72,
                color: isSuccess
                    ? AppColors.success
                    : isFailed
                        ? AppColors.error
                        : AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                isSuccess
                    ? 'پرداخت با موفقیت انجام شد'
                    : isFailed
                        ? 'پرداخت ناموفق بود'
                        : 'در حال پردازش پرداخت',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Center(child: PaymentStatusIndicator(status: _status)),
              if (isFailed) ...[
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.push(RouteNames.orderPay(widget.orderId)),
                  child: const Text('تلاش مجدد پرداخت'),
                ),
              ],
            ],
            const Spacer(),
            OutlinedButton(
              onPressed: () => context.go(RouteNames.orderDetail(widget.orderId)),
              child: const Text('مشاهده سفارش'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(RouteNames.orders),
              child: const Text('بازگشت به سفارش‌ها'),
            ),
          ],
        ),
      ),
    );
  }
}
