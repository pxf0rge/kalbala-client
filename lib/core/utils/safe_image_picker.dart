import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Single-flight image picker — avoids PlatformException(already_active).
abstract final class SafeImagePicker {
  static final ImagePicker _picker = ImagePicker();
  static bool _active = false;

  static Future<XFile?> pickImage({
    ImageSource source = ImageSource.gallery,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    if (_active) return null;
    _active = true;
    try {
      return await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
    } on PlatformException catch (e) {
      if (e.code == 'already_active') return null;
      rethrow;
    } finally {
      _active = false;
    }
  }
}
