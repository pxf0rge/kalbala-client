import 'package:flutter/material.dart';
import 'package:rahmani_project/features/booth/domain/entities/booth_enums.dart';

/// Badge showing verification/application/booth approval status.
class VerificationStatusBadge extends StatelessWidget {
  const VerificationStatusBadge({required this.status, super.key});

  final ApprovalStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      ApprovalStatus.pending => (Colors.orange, Icons.hourglass_top),
      ApprovalStatus.approved => (Colors.green, Icons.check_circle_outline),
      ApprovalStatus.rejected => (Colors.red, Icons.cancel_outlined),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            status.labelFa,
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
