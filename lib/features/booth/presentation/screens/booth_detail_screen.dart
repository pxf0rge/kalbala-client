import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/booth/presentation/providers/booth_provider.dart';
import 'package:rahmani_project/features/booth/presentation/widgets/verification_status_badge.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';
import 'package:rahmani_project/shared/widgets/app_async_error.dart';

/// Seller view of a single booth.
class BoothDetailScreen extends ConsumerWidget {
  const BoothDetailScreen({required this.boothId, super.key});

  final String boothId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boothAsync = ref.watch(boothDetailProvider(boothId));
    final dateFormat = DateFormat('yyyy/MM/dd');

    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات فروشگاه'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(RouteNames.sellerBoothEdit(boothId)),
          ),
        ],
      ),
      body: boothAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppAsyncError(error: e),
        data: (booth) {
          if (booth == null) return const Center(child: Text('فروشگاه یافت نشد'));

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(booth.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              VerificationStatusBadge(status: booth.approvalStatus),
              const SizedBox(height: 16),
              _InfoRow(label: 'نامک', value: booth.slug),
              _InfoRow(label: 'نوع', value: booth.ownershipType.labelFa),
              _InfoRow(label: 'وضعیت', value: booth.isActive ? 'فعال' : 'غیرفعال'),
              if (booth.isRental && booth.rentalStart != null)
                _InfoRow(label: 'شروع اجاره', value: dateFormat.format(booth.rentalStart!)),
              if (booth.isRental && booth.rentalEnd != null)
                _InfoRow(label: 'پایان اجاره', value: dateFormat.format(booth.rentalEnd!)),
              if (booth.phone != null) _InfoRow(label: 'تلفن', value: booth.phone!),
              if (booth.city != null) _InfoRow(label: 'شهر', value: booth.city!),
              if (booth.address != null) _InfoRow(label: 'آدرس', value: booth.address!),
              if (booth.description != null) ...[
                const SizedBox(height: 12),
                Text(booth.description!),
              ],
              if (booth.isRentalExpired) ...[
                const SizedBox(height: 16),
                Text(
                  'مدت اجاره تمام شده. برای تمدید با پشتیبانی تماس بگیرید.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.push(RouteNames.sellerBoothListings(boothId)),
                icon: const Icon(Icons.sell_outlined),
                label: const Text('مدیریت لیستینگ‌ها'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}