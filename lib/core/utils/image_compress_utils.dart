import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Compresses images before upload to stay within storage limits.
abstract final class ImageCompressUtils {
  static const int maxUploadBytes = 1024 * 1024;

  static Future<Uint8List> compressForUpload(
    Uint8List bytes, {
    int maxBytes = maxUploadBytes,
  }) async {
    if (bytes.length <= maxBytes) return bytes;

    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;

    var working = decoded;
    var quality = 85;
    var encoded = Uint8List.fromList(img.encodeJpg(working, quality: quality));

    while (encoded.length > maxBytes && quality > 25) {
      quality -= 10;
      encoded = Uint8List.fromList(img.encodeJpg(working, quality: quality));
    }

    var width = working.width;
    var height = working.height;
    while (encoded.length > maxBytes && width > 320) {
      width = (width * 0.85).round();
      height = (height * 0.85).round();
      working = img.copyResize(working, width: width, height: height);
      encoded = Uint8List.fromList(img.encodeJpg(working, quality: quality));
    }

    return encoded.length <= maxBytes ? encoded : encoded;
  }
}
