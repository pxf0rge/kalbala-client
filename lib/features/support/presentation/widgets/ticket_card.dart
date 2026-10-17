import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rahmani_project/features/support/domain/entities/support_entities.dart';
import 'package:rahmani_project/features/support/presentation/widgets/ticket_status_badge.dart';

/// Card for a support ticket in the list view.
class TicketCard extends StatelessWidget {
  const TicketCard({
    required this.ticket,
    required this.onTap,
    super.key,
  });

  final SupportTicketEntity ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd('fa');

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(ticket.subject),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ticket.lastMessagePreview != null) ...[
              const SizedBox(height: 4),
              Text(
                ticket.lastMessagePreview!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(dateFormat.format(ticket.lastMessageAt ?? ticket.updatedAt)),
          ],
        ),
        trailing: TicketStatusBadge(status: ticket.status),
        isThreeLine: true,
      ),
    );
  }
}
