import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahmani_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:rahmani_project/features/support/domain/entities/support_entities.dart';
import 'package:rahmani_project/features/support/presentation/providers/support_provider.dart';
import 'package:rahmani_project/features/support/presentation/widgets/ticket_message_bubble.dart';
import 'package:rahmani_project/features/support/presentation/widgets/ticket_message_input.dart';
import 'package:rahmani_project/features/support/presentation/widgets/ticket_status_badge.dart';
import 'package:rahmani_project/shared/widgets/app_error_widget.dart';
import 'package:rahmani_project/shared/widgets/app_loading_indicator.dart';

/// Ticket detail with message thread.
class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({required this.ticketId, super.key});

  final String ticketId;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<bool> _sendMessage(String content) async {
    setState(() => _isSending = true);

    final result = await ref.read(sendTicketMessageProvider).call(
          SendTicketMessageInput(
            ticketId: widget.ticketId,
            content: content,
          ),
        );

    if (!mounted) return false;
    setState(() => _isSending = false);

    return result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
        return false;
      },
      (_) {
        ref.invalidate(ticketDetailProvider(widget.ticketId));
        ref.invalidate(myTicketsProvider);
        return true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(ticketDetailProvider(widget.ticketId));
    final currentUserId = ref.watch(authSessionProvider).valueOrNull?.user.id;

    ref.listen(ticketDetailProvider(widget.ticketId), (_, next) {
      if (next.hasValue) _scrollToBottom();
    });

    return Scaffold(
      appBar: AppBar(
        title: detailAsync.maybeWhen(
          data: (detail) => Text(detail.ticket.subject),
          orElse: () => const Text('جزئیات تیکت'),
        ),
        actions: [
          detailAsync.maybeWhen(
            data: (detail) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: TicketStatusBadge(status: detail.ticket.status),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const AppLoadingIndicator(message: 'در حال بارگذاری تیکت...'),
        error: (error, _) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(ticketDetailProvider(widget.ticketId)),
        ),
        data: (detail) {
          final canReply = !detail.ticket.status.isClosed;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  key: const Key('ticket_message_list'),
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: detail.messages.length,
                  itemBuilder: (context, index) {
                    final message = detail.messages[index];
                    final isMine = currentUserId != null &&
                        isTicketMessageFromCurrentUser(
                          senderId: message.senderId,
                          currentUserId: currentUserId,
                        );

                    return TicketMessageBubble(
                      message: message,
                      isMine: isMine,
                    );
                  },
                ),
              ),
              if (canReply)
                TicketMessageInput(
                  isSending: _isSending,
                  onSend: _sendMessage,
                )
              else
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('این تیکت بسته شده است.'),
                ),
            ],
          );
        },
      ),
    );
  }
}