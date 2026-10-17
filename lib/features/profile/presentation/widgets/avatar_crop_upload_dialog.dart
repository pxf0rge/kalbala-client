import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/theme/app_spacing.dart';
import 'package:rahmani_project/core/utils/image_compress_utils.dart';

/// Result of avatar crop+upload dialog: `true` success, `false` failure, `null` cancelled.
Future<bool?> showAvatarCropUploadDialog({
  required BuildContext context,
  required Uint8List imageBytes,
  required Future<bool> Function({
    required List<int> bytes,
    required String fileExtension,
    void Function(double progress, String message)? onProgress,
  }) onUpload,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AvatarCropUploadDialog(
      imageBytes: imageBytes,
      onUpload: onUpload,
    ),
  );
}

class AvatarCropUploadDialog extends StatefulWidget {
  const AvatarCropUploadDialog({
    required this.imageBytes,
    required this.onUpload,
    super.key,
  });

  final Uint8List imageBytes;
  final Future<bool> Function({
    required List<int> bytes,
    required String fileExtension,
    void Function(double progress, String message)? onProgress,
  }) onUpload;

  @override
  State<AvatarCropUploadDialog> createState() => _AvatarCropUploadDialogState();
}

class _AvatarCropUploadDialogState extends State<AvatarCropUploadDialog> {
  final _cropController = CropController();
  bool _cropReady = false;
  bool _isWorking = false;
  double _progress = 0;
  String _message = '';

  void _onCropped(CropResult result) async {
    switch (result) {
      case CropFailure(:final cause):
        if (!mounted) return;
        setState(() {
          _isWorking = false;
          _message = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در برش تصویر: $cause')),
        );
      case CropSuccess(:final croppedImage):
        setState(() {
          _progress = 0.15;
          _message = 'در حال فشرده‌سازی…';
        });
        final compressed =
            await ImageCompressUtils.compressForUpload(croppedImage);
        if (!mounted) return;

        setState(() {
          _progress = 0.35;
          _message = 'در حال آپلود…';
        });

        final success = await widget.onUpload(
          bytes: compressed,
          fileExtension: 'jpg',
          onProgress: (progress, message) {
            if (!mounted) return;
            setState(() {
              // Map upload callback into 0.35–1.0
              _progress = 0.35 + (progress.clamp(0.0, 1.0) * 0.65);
              _message = message;
            });
          },
        );

        if (!mounted) return;
        if (success) {
          setState(() {
            _progress = 1;
            _message = 'آپلود شد';
          });
          Navigator.of(context).pop(true);
        } else {
          setState(() {
            _isWorking = false;
            _progress = 0;
            _message = '';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('خطا در آپلود آواتار')),
          );
        }
    }
  }

  void _confirm() {
    if (_isWorking || !_cropReady) return;
    setState(() {
      _isWorking = true;
      _progress = 0.05;
      _message = 'در حال برش تصویر…';
    });
    _cropController.cropCircle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final cropHeight = (size.height * 0.48).clamp(240.0, 360.0);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'برش عکس پروفایل',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'ناحیه دایره‌ای را تنظیم کنید، سپس آپلود کنید',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.inkMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: cropHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Crop(
                  image: widget.imageBytes,
                  controller: _cropController,
                  aspectRatio: 1,
                  withCircleUi: true,
                  interactive: true,
                  fixCropRect: true,
                  baseColor: AppColors.canvas,
                  maskColor: Colors.black.withValues(alpha: 0.55),
                  progressIndicator: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  onStatusChanged: (status) {
                    if (status == CropStatus.ready && mounted) {
                      setState(() => _cropReady = true);
                    }
                  },
                  onCropped: _onCropped,
                ),
              ),
            ),
            if (_isWorking) ...[
              const SizedBox(height: 14),
              Text(
                _message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: _progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AppColors.hairline,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(_progress.clamp(0.0, 1.0) * 100).round()}٪',
                textAlign: TextAlign.end,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isWorking
                        ? null
                        : () => Navigator.of(context).pop(null),
                    child: const Text('انصراف'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: (_isWorking || !_cropReady) ? null : _confirm,
                    child: Text(_isWorking ? 'در حال آپلود…' : 'تأیید و آپلود'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
