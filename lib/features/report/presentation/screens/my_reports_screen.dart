import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/features/report/presentation/providers/report_provider.dart';
import 'package:rahmani_project/shared/widgets/app_empty_state.dart';
import 'package:rahmani_project/shared/widgets/app_error_widget.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Lists reports submitted by the current user.
class MyReportsScreen extends ConsumerWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(myReportsProvider);
    final dateFormat = DateFormat.yMMMd('fa');

    return Scaffold(
      appBar: AppBar(title: const Text('گزارش‌های من')),
      body: reportsAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری گزارش‌ها...'),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(myReportsProvider),
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return const AppEmptyState(
              icon: Icons.flag_outlined,
              title: 'گزارشی ثبت نشده',
              subtitle: 'هنوز هیچ گزارشی ارسال نکرده‌اید.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                child: ListTile(
                  title: Text('${report.targetType.label} — ${report.reasonLabel}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(report.status.label),
                      Text(dateFormat.format(report.createdAt)),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}