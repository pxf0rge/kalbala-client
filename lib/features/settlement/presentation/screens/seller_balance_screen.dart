import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/settlement/presentation/providers/settlement_provider.dart';
import 'package:rahmani_project/features/settlement/presentation/widgets/balance_summary_card.dart';
import 'package:rahmani_project/shared/widgets/app_error_widget.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Seller finance overview — balance and navigation to settlement tools.
class SellerBalanceScreen extends ConsumerWidget {
  const SellerBalanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(sellerBalanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('مالی و تسویه')),
      body: balanceAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری موجودی...'),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(sellerBalanceProvider),
        ),
        data: (balance) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              BalanceSummaryCard(balance: balance),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.account_balance_outlined),
                      title: const Text('حساب‌های بانکی'),
                      subtitle: const Text('مدیریت حساب برای تسویه'),
                      trailing: const Icon(Icons.chevron_left),
                      onTap: () => context.push(RouteNames.sellerBankAccounts),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.payments_outlined),
                      title: const Text('درخواست تسویه'),
                      subtitle: const Text('برداشت موجودی قابل برداشت'),
                      trailing: const Icon(Icons.chevron_left),
                      onTap: () => context.push(RouteNames.sellerSettlementRequest),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.history_outlined),
                      title: const Text('تاریخچه تسویه'),
                      trailing: const Icon(Icons.chevron_left),
                      onTap: () => context.push(RouteNames.sellerSettlements),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}