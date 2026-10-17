import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/settlement/presentation/providers/settlement_provider.dart';
import 'package:rahmani_project/features/settlement/presentation/widgets/bank_account_card.dart';
import 'package:rahmani_project/shared/widgets/app_empty_state.dart';
import 'package:rahmani_project/shared/widgets/app_error_widget.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// List of seller bank accounts.
class BankAccountsScreen extends ConsumerWidget {
  const BankAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(bankAccountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('حساب‌های بانکی')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.sellerBankAccountAdd),
        icon: const Icon(Icons.add),
        label: const Text('حساب جدید'),
      ),
      body: accountsAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری حساب‌ها...'),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(bankAccountsProvider),
        ),
        data: (accounts) {
          if (accounts.isEmpty) {
            return const AppEmptyState(
              icon: Icons.account_balance_outlined,
              title: 'حساب بانکی ثبت نشده',
              subtitle: 'برای درخواست تسویه، ابتدا حساب بانکی اضافه کنید.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: accounts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final account = accounts[index];
              return BankAccountCard(
                account: account,
                onDelete: account.isVerified
                    ? null
                    : () => _deleteAccount(context, ref, account.id),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref, String accountId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف حساب بانکی'),
        content: const Text('این حساب بانکی حذف شود؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final result = await ref.read(deleteBankAccountProvider).call(accountId);
    if (!context.mounted) return;

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) {
        ref.invalidate(bankAccountsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حساب بانکی حذف شد')),
        );
      },
    );
  }
}