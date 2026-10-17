import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/features/settlement/presentation/providers/settlement_provider.dart';
import 'package:rahmani_project/features/settlement/presentation/widgets/settlement_tile.dart';
import 'package:rahmani_project/shared/widgets/app_empty_state.dart';
import 'package:rahmani_project/shared/widgets/app_error_widget.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// History of seller settlement requests.
class SettlementHistoryScreen extends ConsumerWidget {
  const SettlementHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settlementsAsync = ref.watch(settlementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تاریخچه تسویه')),
      body: settlementsAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری تاریخچه...'),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(settlementsProvider),
        ),
        data: (settlements) {
          if (settlements.isEmpty) {
            return const AppEmptyState(
              icon: Icons.history_outlined,
              title: 'درخواست تسویه‌ای ثبت نشده',
              subtitle: 'پس از ثبت درخواست تسویه، اینجا نمایش داده می‌شود.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: settlements.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) => SettlementTile(settlement: settlements[index]),
          );
        },
      ),
    );
  }
}