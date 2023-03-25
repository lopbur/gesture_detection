import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../util/converter.dart';

typedef Handler = Future<dynamic> Function(Map<String, dynamic>);
typedef HandlerParam = Map<String, dynamic>;

final handlerProvider =
    StateNotifierProvider<HandlerProvider, Map<String, Handler>>(
  (ref) {
    return HandlerProvider({
      'isolate_sendImageStream': HandlerProvider.sndimgstrmIsolate,
      'isolate_sendImageSequences': HandlerProvider.sndimgsqnceIsolater,
      'isolate_convertImageToYUV': HandlerProvider.cnvrtcmrimgyuvIsolate,
    });
  },
);

class HandlerProvider extends StateNotifier<Map<String, Handler>> {
  HandlerProvider(Map<String, Handler>? init) : super({...init ?? {}});
  Map<String, Handler>? init;

  void register(String description, Handler body) {
    state = {
      ...state,
      ...{description: body}
    };
  }

  void remove(String description) {
    final updatedState = Map<String, Handler>.from(state);
    updatedState.remove(description);
    state = updatedState;
  }

  /// Call the handler registered as a [description] in the [handlerProvider] with [parameter]
  ///
  /// ```
  /// ref.watch(handlerProvider.notifier).call('isolate_sendImageStream', {'image': cameraImageStream});
  /// ```
  dynamic call(String description, HandlerParam parameter) {
    return state[description]?.call(parameter);
  }

  /// Return [Uint8List] (YUV420 format) converted from [CameraImage].
  ///
  /// params must be included ['image'] key of type [CameraImage].
  static Future<dynamic> sndimgstrmIsolate(HandlerParam params) async {
    final data = params['image'] as CameraImage;
    final result = Uint8List(
        data.planes.fold(0, (count, plane) => count + plane.bytes.length));
    int offset = 0;
    for (final plane in data.planes) {
      result.setRange(offset, offset + plane.bytes.length, plane.bytes);
      offset += plane.bytes.length;
    }

    return result;
  }

  /// Return [Uint8List] (YUV420 format -> RGB format) converted from [CameraImage].
  ///
  /// params must be included ['image'] key of type [CameraImage].
  static Future<dynamic> cnvrtcmrimgyuvIsolate(HandlerParam params) async {
    final image = params['image'] as CameraImage;
    final byte = await ImageConverter.convertYUV420ToRGBByte(image);
    return byte;
  }

  /// Return [Uint8List] (YUV420 format) planes converted from List<Uint8List> image sequence.
  static Future<dynamic> sndimgsqnceIsolater(
    dynamic params,
  ) async {
    return 0;
  }
}
