import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/constants/app_constants.dart';
import 'package:rahmani_project/features/settlement/domain/entities/settlement_entities.dart';
import 'package:rahmani_project/features/settlement/presentation/providers/settlement_provider.dart';
import 'package:rahmani_project/shared/widgets/app_error_widget.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Form to request a settlement withdrawal.
class SettlementRequestScreen extends ConsumerStatefulWidget {
  const SettlementRequestScreen({super.key});

  @override
  ConsumerState<SettlementRequestScreen> createState() => _SettlementRequestScreenState();
}

class _SettlementRequestScreenState extends ConsumerState<SettlementRequestScreen> {
  final _amountController = TextEditingController();
  String? _selectedAccountId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(sellerBalanceProvider);
    final accountsAsync = ref.watch(bankAccountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('درخواست تسویه')),
      body: balanceAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری...'),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(sellerBalanceProvider);
            ref.invalidate(bankAccountsProvider);
          },
        ),
        data: (balance) {
          return accountsAsync.when(
            loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری حساب‌ها...'),
            error: (error, _) => AppErrorWidget(
              message: error.toString(),
              onRetry: () => ref.invalidate(bankAccountsProvider),
            ),
            data: (accounts) {
              final verifiedAccounts =
                  accounts.where((account) => account.isVerified).toList();
              final priceFormat = NumberFormat('#,##0', 'fa');

              if (verifiedAccounts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.account_balance_outlined, size: 48),
                        const SizedBox(height: 16),
                        const Text(
                          'حساب بانکی تأییدشده‌ای ندارید',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'ابتدا حساب بانکی اضافه کنید و منتظر تأیید ادمین بمانید.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              _selectedAccountId ??= verifiedAccounts.first.id;

              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Card(
                    child: ListTile(
                      title: const Text('موجودی قابل برداشت'),
                      trailing: Text(
                        '${priceFormat.format(balance.availableBalance)} ${AppConstants.currencySymbol}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedAccountId,
                    decoration: const InputDecoration(
                      labelText: 'حساب بانکی',
                      border: OutlineInputBorder(),
                    ),
                    items: verifiedAccounts
                        .map(
                          (account) => DropdownMenuItem(
                            value: account.id,
                            child: Text('${account.bankName} — ${account.maskedAccountNumber}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _selectedAccountId = value),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'مبلغ تسویه',
                      suffixText: AppConstants.currencySymbol,
                      border: const OutlineInputBorder(),
                      helperText:
                          'حداکثر ${priceFormat.format(balance.availableBalance)} ${AppConstants.currencySymbol}',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isSubmitting ? null : () => _submit(balance.availableBalance),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('ثبت درخواست تسویه'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _submit(double availableBalance) async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مبلغ نامعتبر است')),
      );
      return;
    }

    final accountId = _selectedAccountId;
    if (accountId == null) return;

    setState(() => _isSubmitting = true);

    final result = await ref.read(requestSettlementProvider).call(
          RequestSettlementInput(amount: amount, bankAccountId: accountId),
          availableBalance: availableBalance,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) {
        ref.invalidate(sellerBalanceProvider);
        ref.invalidate(settlementsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('درخواست تسویه ثبت شد')),
        );
        context.pop();
      },
    );
  }
}