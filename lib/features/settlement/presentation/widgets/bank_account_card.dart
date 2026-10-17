import 'package:flutter/material.dart';
import 'package:rahmani_project/features/settlement/domain/entities/settlement_entities.dart';

/// Card displaying a seller bank account.
class BankAccountCard extends StatelessWidget {
  const BankAccountCard({
    required this.account,
    this.onDelete,
    super.key,
  });

  final BankAccountEntity account;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          account.isVerified ? Icons.verified_outlined : Icons.account_balance_outlined,
          color: account.isVerified ? Colors.green : null,
        ),
        title: Text(account.bankName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${account.accountHolder} — ${account.maskedAccountNumber}'),
            const SizedBox(height: 4),
            Text(
              account.isVerified ? 'تأیید شده' : 'در انتظار تأیید ادمین',
              style: TextStyle(
                color: account.isVerified
                    ? Colors.green.shade700
                    : Theme.of(context).colorScheme.outline,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: account.isVerified || onDelete == null
            ? null
            : IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              ),
      ),
    );
  }
}
