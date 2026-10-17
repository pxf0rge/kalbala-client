import 'package:flutter/material.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';

/// Shared linear upload / submit progress with Persian percent label.
class AppUploadProgressBar extends StatelessWidget {
  const AppUploadProgressBar({
    required this.progress,
    required this.message,
    super.key,
  });

  final double progress;
  final String message;

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.inkMuted,
              ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: AppColors.hairline,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(value * 100).round()}٪',
          textAlign: TextAlign.end,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.inkMuted,
              ),
        ),
      ],
    );
  }
}
