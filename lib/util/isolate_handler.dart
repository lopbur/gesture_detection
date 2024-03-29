import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:camera/camera.dart';

import '../util/converter.dart';

typedef Handler = Future<dynamic> Function(Map<String, dynamic>);
typedef HandlerParam = Map<String, dynamic>;

class IsolateHandler {
  /// Return [bytes] (YUV420 format) converted from [CameraImage].
  ///
  /// params must be included ['image'] key of type [CameraImage].
  static Future<dynamic> cnvrtCMRToByte(HandlerParam params) async {
    if (!params.containsKey('image')) return;
    if (params['image'] is! CameraImage) return;

    final data = params['image'] as CameraImage;
    final result = Uint8List(
        data.planes.fold(0, (count, plane) => count + plane.bytes.length));
    int offset = 0;
    for (final plane in data.planes) {
      result.setRange(offset, offset + plane.bytes.length, plane.bytes);
      offset += plane.bytes.length;
    }

    return result.toList();
  }

  static Future<dynamic> cnvrtCMRToGrayscaleByte(HandlerParam params) async {
    if (!params.containsKey('image')) return;
    if (params['image'] is! CameraImage) return;
    final data = params['image'] as CameraImage;

    // Convert YUV420 to grayscale image
    final width = data.width;
    final height = data.height;
    final yPlane = data.planes[0].bytes;
    final grayscale = Uint8List(width * height);
    int grayOffset = 0;
    for (int i = 0; i < height; i++) {
      int rowOffset = i * data.planes[0].bytesPerRow;
      for (int j = 0; j < width; j++) {
        grayscale[grayOffset++] = yPlane[rowOffset + j];
      }
    }

    return grayscale.toList();
  }

  /// Return [Uint8List] (YUV420 format) planes converted from List<Uint8List> image sequence.
  ///
  /// params must be included ['list'] key of type [List] contain [Uint8List].
  static Future<dynamic> cnvrtIMGSeqToByte(HandlerParam params) async {
    if (!params.containsKey('list')) return;
    if (params['list'] is! List<Uint8List>) return;

    final seqs = params['list'] as List<Uint8List>;
    if (seqs.isEmpty) return;

    final result =
        Uint8List((seqs.fold(0, (count, seq) => count + seq.length + 4 * 1)));
    int offset = 0;
    for (final seq in seqs) {
      final seqLength = seq.length;
      result.buffer.asByteData().setUint32(offset, seqLength, Endian.little);
      offset += 4;
      result.setRange(offset, offset + seq.length, seq);
      offset += seq.length;
    }

    return result;
  }

  /// Return [Uint8List] (YUV420 format -> RGB format) converted from [CameraImage].
  ///
  /// params must be included ['image'] key of type [CameraImage].
  static Future<dynamic> cnvrtCMRToRGB(HandlerParam params) async {
    try {
      final image = params['image'] as CameraImage;
      final byte = await ImageConverter.convertYUV420ToRGBByte(image);
      return byte;
    } catch (e) {
      dev.log('Unexpected error has occured: ${e.toString()}');
    }
    return null;
  }
}
