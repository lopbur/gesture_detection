import 'package:flutter/material.dart';
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
      print(
          '>>>>>> Error has occured while convert YUV420 to Bytelist: ${e.toString()}');
    }

    return null;
  }

  static Future<Uint8List?> convertYUV420ToRGBByteList(
    CameraImage image,
  ) async {
    try {
      var width = image.width;
      var height = image.height;

      var yPlane = image.planes[0].bytes;
      var uPlane = image.planes[1].bytes;
      var vPlane = image.planes[2].bytes;

      final yRowStride = image.planes[0].bytesPerRow;
      final uvRowStride = image.planes[1].bytesPerRow;
      final uvPixelStride = image.planes[1].bytesPerPixel!;

      // Allocate memory for the output RGB byte list
      var rgbData = Uint8List(width * height * 3);

      // YUV to RGB conversion
      var pRGB = 0;
      for (var h = 0; h < height; h++) {
        for (var w = 0; w < width; w++) {
          final pUV =
              uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
          final pY = h * yRowStride + w;
          var y = yPlane[pY];
          var u = uPlane[pUV];
          var v = vPlane[pUV];

          var r = (y + 1.13983 * (v - 128)).round().clamp(0, 255);
          var g = (y - 0.39465 * (u - 128) - 0.5806 * (v - 128))
              .round()
              .clamp(0, 255);
          var b = (y + 2.03211 * (u - 128)).round().clamp(0, 255);

          rgbData[pRGB++] = r;
          rgbData[pRGB++] = g;
          rgbData[pRGB++] = b;
        }
      }
      return rgbData;
    } catch (e) {
      print(
          '>>>>>> Error has occured while convert YUV420 to RGB Bytelist: ${e.toString()}');
    }

    return null;
  }

  static Future<Image?> convertYUV420ToRGB(CameraImage cameraImage) async {
    try {
      const shift = (0xFF << 24);

      final width = cameraImage.width;
      final height = cameraImage.height;

      final yRowStride = cameraImage.planes[0].bytesPerRow;
      final uvRowStride = cameraImage.planes[1].bytesPerRow;
      final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

      final image = image_lib.Image(
        width: width,
        height: height,
      );

      for (var w = 0; w < width; w++) {
        for (var h = 0; h < height; h++) {
          final uvIndex =
              uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
          final index = h * width + w;
          final yIndex = h * yRowStride + w;

          final yp = cameraImage.planes[0].bytes[yIndex];
          final up = cameraImage.planes[1].bytes[uvIndex];
          final vp = cameraImage.planes[2].bytes[uvIndex];

          int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
          int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
              .round()
              .clamp(0, 255);
          int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

          if (image.isBoundsSafe(height - h, w)) {
            image.setPixelRgba(height - h, w, r, g, b, shift);
          }
        }
      }
      image_lib.PngEncoder pngEncoder =
          image_lib.PngEncoder(level: 0, filter: image_lib.PngFilter.none);
      Uint8List png = pngEncoder.encode(image);
      return Image.memory(png);
    } catch (e) {
      print(
          '>>>>>> Error has occured while convert YUV420 to RGB: ${e.toString()}');
    }
    return null;
  }
}
