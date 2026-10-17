import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/utils/phone_utils.dart';
import 'package:rahmani_project/features/profile/presentation/providers/profile_provider.dart';

/// Edit profile name + link to change phone (OTP-gated).
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _initializeFromProfile() {
    if (_initialized) return;
    final profile = ref.read(profileProvider).valueOrNull;
    _nameController.text = profile?.fullName ?? '';
    _initialized = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final success = await ref.read(profileProvider.notifier).updateName(
          _nameController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      context.pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('خطا در ذخیره پروفایل')),
    );
  }

  @override
  Widget build(BuildContext context) {
    _initializeFromProfile();
    final phone = ref.watch(profileProvider).valueOrNull?.phone;

    return Scaffold(
      appBar: AppBar(title: const Text('ویرایش پروفایل')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'نام و نام خانوادگی',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'نام را وارد کنید';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'شماره موبایل',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        phone == null || phone.isEmpty
                            ? '—'
                            : PhoneUtils.formatForDisplay(phone),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(RouteNames.profileChangePhone),
                      child: const Text('تغییر شماره'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'شماره موبایل فقط با تأیید کد OTP شماره جدید قابل تغییر است.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.inkMuted,
                    ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('ذخیره'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}