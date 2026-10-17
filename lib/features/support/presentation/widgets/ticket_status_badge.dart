import 'package:flutter/material.dart';
import 'package:rahmani_project/features/support/domain/entities/support_entities.dart';

/// Badge showing ticket status with color coding.
class TicketStatusBadge extends StatelessWidget {
  const TicketStatusBadge({
    required this.status,
    super.key,
  });

  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      TicketStatus.open => Colors.orange,
      TicketStatus.inProgress => Colors.blue,
      TicketStatus.resolved => Colors.green,
      TicketStatus.closed => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}
