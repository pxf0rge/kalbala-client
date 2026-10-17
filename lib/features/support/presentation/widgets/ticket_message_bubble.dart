import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/features/support/domain/entities/support_entities.dart';
import 'package:rahmani_project/features/support/presentation/providers/support_provider.dart';

/// Single message bubble in a support ticket thread.
class TicketMessageBubble extends ConsumerWidget {
  const TicketMessageBubble({
    required this.message,
    required this.isMine,
    super.key,
  });

  final TicketMessageEntity message;
  final bool isMine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeFormat = DateFormat.Hm('fa');
    final alignment = isMine ? Alignment.centerLeft : Alignment.centerRight;
    final color = isMine
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.isAdminReply)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'پشتیبانی',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              Text(message.content),
              if (message.attachmentPath != null) ...[
                const SizedBox(height: 8),
                _AttachmentPreview(path: message.attachmentPath!),
              ],
              const SizedBox(height: 4),
              Text(
                timeFormat.format(message.createdAt),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentPreview extends ConsumerWidget {
  const _AttachmentPreview({required this.path});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlAsync = ref.watch(signedAttachmentUrlProvider(path));

    return urlAsync.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => const Text('خطا در بارگذاری پیوست'),
      data: (url) {
        if (path.toLowerCase().endsWith('.pdf')) {
          return Text('پیوست PDF', style: Theme.of(context).textTheme.bodySmall);
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: url,
            height: 120,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
