import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rahmani_project/core/utils/safe_image_picker.dart';
import 'package:rahmani_project/features/profile/presentation/widgets/avatar_crop_upload_dialog.dart';

/// Avatar display with crop dialog and upload progress.
class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    required this.avatarUrl,
    required this.onUpload,
    this.size = 96,
    super.key,
  });

  final String? avatarUrl;
  final Future<bool> Function({
    required List<int> bytes,
    required String fileExtension,
    void Function(double progress, String message)? onProgress,
  }) onUpload;
  final double size;

  Future<void> _pickImage(BuildContext context) async {
    final file = await SafeImagePicker.pickImage(
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 92,
    );
    if (file == null || !context.mounted) return;

    final bytes = Uint8List.fromList(await file.readAsBytes());
    if (!context.mounted) return;

    final result = await showAvatarCropUploadDialog(
      context: context,
      imageBytes: bytes,
      onUpload: onUpload,
    );

    if (!context.mounted || result == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result ? 'آواتار به‌روزرسانی شد' : 'خطا در آپلود آواتار'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          key: ValueKey(avatarUrl ?? 'empty'),
          radius: size / 2,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
              ? CachedNetworkImageProvider(avatarUrl!)
              : null,
          child: avatarUrl == null || avatarUrl!.isEmpty
              ? Icon(Icons.person, size: size / 2, color: Theme.of(context).colorScheme.primary)
              : null,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Material(
            color: Theme.of(context).colorScheme.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => _pickImage(context),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
