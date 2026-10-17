import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/features/settlement/domain/entities/settlement_entities.dart';
import 'package:rahmani_project/features/settlement/presentation/providers/settlement_provider.dart';

/// Form to register a new bank account.
class AddBankAccountScreen extends ConsumerStatefulWidget {
  const AddBankAccountScreen({super.key});

  @override
  ConsumerState<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends ConsumerState<AddBankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('افزودن حساب بانکی')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _bankNameController,
              decoration: const InputDecoration(
                labelText: 'نام بانک',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'نام بانک الزامی است' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _accountNumberController,
              decoration: const InputDecoration(
                labelText: 'شماره حساب',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'شماره حساب الزامی است' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _accountHolderController,
              decoration: const InputDecoration(
                labelText: 'نام صاحب حساب',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'نام صاحب حساب الزامی است' : null,
            ),
            const SizedBox(height: 8),
            Text(
              'پس از ثبت، حساب توسط ادمین تأیید می‌شود و سپس قابل استفاده برای تسویه خواهد بود.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('ثبت حساب'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final input = AddBankAccountInput(
      bankName: _bankNameController.text,
      accountNumber: _accountNumberController.text,
      accountHolder: _accountHolderController.text,
    );

    final result = await ref.read(addBankAccountProvider).call(input);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) {
        ref.invalidate(bankAccountsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حساب بانکی ثبت شد')),
        );
        context.pop();
      },
    );
  }
}