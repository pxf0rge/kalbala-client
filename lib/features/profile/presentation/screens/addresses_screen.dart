import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/profile/domain/entities/address_entity.dart';
import 'package:rahmani_project/features/profile/presentation/providers/profile_provider.dart';
import 'package:rahmani_project/features/profile/presentation/widgets/address_card.dart';
import 'package:rahmani_project/shared/widgets/app_empty_state.dart';
import 'package:rahmani_project/shared/widgets/app_error_widget.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// List of user delivery addresses.
class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('آدرس‌های تحویل')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.profileAddressAdd),
        icon: const Icon(Icons.add),
        label: const Text('آدرس جدید'),
      ),
      body: addressesAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری آدرس‌ها...'),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(addressesProvider),
        ),
        data: (addresses) {
          if (addresses.isEmpty) {
            return const AppEmptyState(
              icon: Icons.location_off_outlined,
              title: 'آدرسی ثبت نشده',
              subtitle: 'برای تحویل سفارش، یک آدرس اضافه کنید.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final address = addresses[index];
              return AddressCard(
                address: address,
                onTap: () => context.push(
                  RouteNames.profileAddressEdit(address.id),
                  extra: address,
                ),
                onSetDefault: () => _setDefault(context, ref, address),
                onDelete: () => _delete(context, ref, address),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _setDefault(BuildContext context, WidgetRef ref, AddressEntity address) async {
    final success = await ref.read(addressesProvider.notifier).setDefault(address.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'آدرس پیش‌فرض تنظیم شد' : 'خطا در تنظیم آدرس پیش‌فرض')),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, AddressEntity address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف آدرس'),
        content: Text('آدرس «${address.label}» حذف شود؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final success = await ref.read(addressesProvider.notifier).remove(address.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'آدرس حذف شد' : 'خطا در حذف آدرس')),
    );
  }
}