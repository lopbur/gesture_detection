import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';

import '../provider/client.provider.dart';
import '../provider/control.provider.dart';
import '../provider/handler.provider.dart';
import '../util/isolate_util.dart';

import 'widget/camera_preview_wrapper.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  final IsolateUtils _isolateUtils = IsolateUtils();

  @override
  void initState() {
    super.initState();
    _isolateUtils.initIsolate();

    // Future.microtask(() => ref.watch(clientProvider.notifier).connect());
  }

  @override
  void dispose() {
    _isolateUtils.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final control = ref.watch(controlProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Gesture Detection'),
          actions: [
            IconButton(
              onPressed: () =>
                  ref.watch(controlProvider.notifier).toggleCameraFront(),
              icon: const Icon(Icons.flip),
            ),
            IconButton(
              onPressed: () =>
                  ref.watch(controlProvider.notifier).rotateCamera(),
              icon: const Icon(Icons.rotate_right),
            ),
            IconButton(
              onPressed: () {
                ref.watch(controlProvider.notifier).toggleCameraStream();
              },
              icon: Icon(control.isCameraStreamStarted
                  ? Icons.stop
                  : Icons.play_arrow),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: CameraPreviewWrapper(streamHandler: cameraStreamHandler),
            ),
            Expanded(flex: 1, child: Container())
          ],
        ));
  }

  void cameraStreamHandler(CameraImage image) {
    final handler = ref.watch(handlerProvider)['isolate_cvCMRToByte'];
    if (handler == null) return;

    if (ref.watch(isolateFlagProvider)) return;
    ref.watch(isolateFlagProvider.notifier).state = true;
    Future.delayed(
      Duration(milliseconds: ref.watch(controlProvider).frameInterval),
      () {
        if (ref.watch(isolateFlagProvider)) return;
        ref.watch(isolateFlagProvider.notifier).state = true;

        _isolateSpawn(
          handler,
          {'image': image},
          (result) {
            final data = {
              'byte': result,
              'height': image.height,
              'width': image.width,
            };

            ref
                .watch(clientProvider.notifier)
                .send(MessageType.handStream, data);
          },
        );
        ref.watch(isolateFlagProvider.notifier).state = false;
      },
    );
  }

  dynamic _isolateSpawn(
      Future<dynamic> Function(Map<String, dynamic>) isolateHandler,
      Map<String, dynamic>? handlerParameter,
      void Function(dynamic) postCallback) async {
    final responsePort = ReceivePort();

    _isolateUtils.sendMessage(
      isolateHandler,
      _isolateUtils.sendPort,
      responsePort,
      params: handlerParameter ?? {},
    );

    postCallback(await responsePort.first);
  }

  // static Future<dynamic> isolateHandler(dynamic params) async {
  //   final data = params['image'] as CameraImage;
  //   final result = Uint8List(
  //       data.planes.fold(0, (count, plane) => count + plane.bytes.length));
  //   int offset = 0;
  //   for (final plane in data.planes) {
  //     result.setRange(offset, offset + plane.bytes.length, plane.bytes);
  //     offset += plane.bytes.length;
  //   }

  //   return result;
  // }
}
