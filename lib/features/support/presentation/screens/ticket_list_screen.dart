import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/support/presentation/providers/support_provider.dart';
import 'package:rahmani_project/features/support/presentation/widgets/ticket_card.dart';
import 'package:rahmani_project/shared/widgets/app_empty_state.dart';
import 'package:rahmani_project/shared/widgets/app_error_widget.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Lists support tickets submitted by the current user.
class TicketListScreen extends ConsumerWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(myTicketsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('پشتیبانی')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.supportCreate),
        icon: const Icon(Icons.add),
        label: const Text('تیکت جدید'),
      ),
      body: ticketsAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری تیکت‌ها...'),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(myTicketsProvider),
        ),
        data: (tickets) {
          if (tickets.isEmpty) {
            return const AppEmptyState(
              icon: Icons.support_agent_outlined,
              title: 'تیکتی ثبت نشده',
              subtitle: 'برای ارتباط با پشتیبانی، تیکت جدید ایجاد کنید.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myTicketsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: tickets.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return TicketCard(
                  ticket: ticket,
                  onTap: () => context.push(RouteNames.ticketDetail(ticket.id)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}