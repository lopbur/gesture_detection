import 'dart:developer';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as image_lib;

class Uint8ListConverter implements JsonConverter<Uint8List, Object> {
  const Uint8ListConverter();

  @override
  Uint8List fromJson(Object json) {
    if (json is List<dynamic>) {
      return Uint8List.fromList(json.cast<int>());
    } else {
      throw ArgumentError('Invalid type for Uint8List: ${json.runtimeType}');
    }
  }

  @override
  Object toJson(Uint8List list) {
    return list.toList();
  }
}

class ImageConverter {
  const ImageConverter();

  static Future<Uint8List?> convertCameraImageToByteList(
    CameraImage image,
  ) async {
    try {
      final result = Uint8List(
          image.planes.fold(0, (count, plane) => count + plane.bytes.length));
      int offset = 0;
      for (final plane in image.planes) {
        result.setRange(offset, offset + plane.bytes.length, plane.bytes);
        offset += plane.bytes.length;
      }

      return result;
    } catch (e) {
      log('>>>>>> Error has occured while convert YUV420 to Bytelist: ${e.toString()}');
    }

    return null;
  }

  static Future<Uint8List?> convertYUV420ToRGBByte(
    CameraImage cameraImage,
  ) async {
    const shift = (0xFF << 24);
    final imageWidth = cameraImage.width;
    final imageHeight = cameraImage.height;

    final yBuffer = cameraImage.planes[0].bytes;
    final uBuffer = cameraImage.planes[1].bytes;
    final vBuffer = cameraImage.planes[2].bytes;

    final int yRowStride = cameraImage.planes[0].bytesPerRow;
    final int yPixelStride = cameraImage.planes[0].bytesPerPixel!;

    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    final image = image_lib.Image(width: imageWidth, height: imageHeight);

    try {
      for (int h = 0; h < imageHeight; h++) {
        int uvh = (h / 2).floor();

        for (int w = 0; w < imageWidth; w++) {
          int uvw = (w / 2).floor();

          final yIndex = (h * yRowStride) + (w * yPixelStride);

          // Y plane should have positive values belonging to [0...255]
          final int y = yBuffer[yIndex];

          // U/V Values are subsampled i.e. each pixel in U/V chanel in a
          // YUV_420 image act as chroma value for 4 neighbouring pixels
          final int uvIndex = (uvh * uvRowStride) + (uvw * uvPixelStride);

          // U/V values ideally fall under [-0.5, 0.5] range. To fit them into
          // [0, 255] range they are scaled up and centered to 128.
          // Operation below brings U/V values to [-128, 127].
          final int u = uBuffer[uvIndex];
          final int v = vBuffer[uvIndex];

          // Compute RGB values per formula above.
          int r = (y + v * 1436 / 1024 - 179).round();
          int g =
              (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
          int b = (y + u * 1814 / 1024 - 227).round();

          r = r.clamp(0, 255);
          g = g.clamp(0, 255);
          b = b.clamp(0, 255);

          // Use 255 for alpha value, no transparency. ARGB values are
          // positioned in each byte of a single 4 byte integer
          // [AAAAAAAARRRRRRRRGGGGGGGGBBBBBBBB]
          final int argbIndex = h * imageWidth + w;

          image.setPixelRgba(w, h, r, g, b, shift);
        }
      }

      image_lib.PngEncoder pngEncoder =
          image_lib.PngEncoder(level: 0, filter: image_lib.PngFilter.none);
      Uint8List bytes = pngEncoder.encode(image);

      return bytes;
    } catch (e) {
      log('>>>>>> Error has occured while convert YUV420 to RGB: ${e.toString()}');
    }
    return null;
  }
}
