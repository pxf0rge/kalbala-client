import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';

/// Progress for booth logo/cover upload flows.
typedef BoothUploadProgress = void Function(double progress, String message);

/// Image pick/upload slot with optional preview and progress bar.
class BoothImageUploadTile extends StatelessWidget {
  const BoothImageUploadTile({
    required this.title,
    required this.emptyLabel,
    required this.icon,
    required this.onPick,
    this.bytes,
    this.enabled = true,
    this.busy = false,
    this.busyLabel,
    this.progress,
    super.key,
  });

  final String title;
  final String emptyLabel;
  final IconData icon;
  final VoidCallback? onPick;
  final List<int>? bytes;
  final bool enabled;
  final bool busy;
  final String? busyLabel;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = bytes != null && bytes!.isNotEmpty;

    return Material(
      color: AppColors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: enabled && !busy ? onPick : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: hasImage
                          ? Image.memory(
                              Uint8List.fromList(bytes!),
                              fit: BoxFit.cover,
                            )
                          : ColoredBox(
                              color: AppColors.primarySoft,
                              child: Icon(icon, color: AppColors.primary),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.titleSmall),
                        const SizedBox(height: 2),
                        Text(
                          busy
                              ? (busyLabel ?? 'در حال آپلود…')
                              : hasImage
                                  ? 'انتخاب شد — برای تغییر ضربه بزنید'
                                  : emptyLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (busy)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      hasImage ? Icons.check_circle : Icons.add_photo_alternate_outlined,
                      color: hasImage ? AppColors.success : AppColors.inkMuted,
                    ),
                ],
              ),
              if (busy) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.hairline,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-width submit progress strip.
class BoothSubmitProgressBar extends StatelessWidget {
  const BoothSubmitProgressBar({
    required this.progress,
    required this.message,
    super.key,
  });

  final double progress;
  final String message;

  @override
  Widget build(BuildContext context) {
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
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.hairline,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress.clamp(0.0, 1.0) * 100).round()}٪',
          textAlign: TextAlign.end,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.inkMuted,
              ),
        ),
      ],
    );
  }
}
