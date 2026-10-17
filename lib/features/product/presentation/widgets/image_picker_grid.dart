import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rahmani_project/core/theme/app_colors.dart';
import 'package:rahmani_project/core/utils/image_compress_utils.dart';
import 'package:rahmani_project/core/utils/safe_image_picker.dart';

typedef ProductImagesChanged = void Function({
  required List<String> keptUrls,
  required List<Uint8List> newBytes,
  required List<String> newExtensions,
});

/// Grid for picking product images (existing URLs + new picks).
class ImagePickerGrid extends StatefulWidget {
  const ImagePickerGrid({
    required this.existingImageUrls,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final List<String> existingImageUrls;
  final ProductImagesChanged onChanged;
  final bool enabled;

  @override
  State<ImagePickerGrid> createState() => _ImagePickerGridState();
}

class _ImagePickerGridState extends State<ImagePickerGrid> {
  late List<String> _keptUrls;
  final List<Uint8List> _newBytes = [];
  final List<String> _newExtensions = [];
  bool _picking = false;
  double? _pickProgress;

  @override
  void initState() {
    super.initState();
    _keptUrls = List.from(widget.existingImageUrls);
  }

  void _notify() {
    widget.onChanged(
      keptUrls: _keptUrls,
      newBytes: List.from(_newBytes),
      newExtensions: List.from(_newExtensions),
    );
  }

  Future<void> _pickImage() async {
    if (!widget.enabled || _picking) return;
    setState(() {
      _picking = true;
      _pickProgress = null;
    });
    try {
      final file = await SafeImagePicker.pickImage(
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      setState(() => _pickProgress = 0.4);
      final bytes =
          await ImageCompressUtils.compressForUpload(await file.readAsBytes());
      final ext = file.path.split('.').last.toLowerCase();
      if (!mounted) return;
      setState(() {
        _newBytes.add(bytes);
        _newExtensions.add(ext == 'jpeg' ? 'jpg' : ext);
        _pickProgress = 1;
      });
      _notify();
    } finally {
      if (mounted) {
        setState(() {
          _picking = false;
          _pickProgress = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _keptUrls.length + _newBytes.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('تصاویر محصول', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < _keptUrls.length; i++)
              _ImageThumb(
                image: CachedNetworkImageProvider(_keptUrls[i]),
                onRemove: widget.enabled && !_picking
                    ? () {
                        setState(() => _keptUrls.removeAt(i));
                        _notify();
                      }
                    : null,
              ),
            for (var i = 0; i < _newBytes.length; i++)
              _ImageThumb(
                image: MemoryImage(_newBytes[i]),
                onRemove: widget.enabled && !_picking
                    ? () {
                        setState(() {
                          _newBytes.removeAt(i);
                          _newExtensions.removeAt(i);
                        });
                        _notify();
                      }
                    : null,
              ),
            if (total < 6)
              InkWell(
                onTap: widget.enabled && !_picking ? _pickImage : null,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.secondarySoft,
                  ),
                  child: _picking
                      ? Padding(
                          padding: const EdgeInsets.all(18),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: _pickProgress,
                          ),
                        )
                      : const Icon(Icons.add_photo_alternate_outlined),
                ),
              ),
          ],
        ),
        if (_picking) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: _pickProgress,
              minHeight: 4,
              backgroundColor: AppColors.hairline,
              color: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.image, this.onRemove});

  final ImageProvider image;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image(image: image, width: 80, height: 80, fit: BoxFit.cover),
        ),
        if (onRemove != null)
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(2),
                minimumSize: const Size(24, 24),
              ),
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 16),
            ),
          ),
      ],
    );
  }
}
