import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rahmani_project/core/routing/route_names.dart';
import 'package:rahmani_project/features/report/domain/entities/report_entities.dart';

/// Navigates to the report submission screen.
void openReportScreen(BuildContext context, ReportTarget target) {
  context.push(RouteNames.report, extra: target);
}

/// App bar action to open report screen.
class ReportIconButton extends StatelessWidget {
  const ReportIconButton({
    required this.target,
    super.key,
  });

  final ReportTarget target;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'گزارش تخلف',
      icon: const Icon(Icons.flag_outlined),
      onPressed: () => openReportScreen(context, target),
    );
  }
}
