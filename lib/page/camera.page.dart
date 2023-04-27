import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:gesture_detection/util/isolate_handler.dart';

import '../provider/client.provider.dart';
import '../provider/control.provider.dart';
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
            onPressed: () => ref.watch(controlProvider.notifier).rotateCamera(),
            icon: const Icon(Icons.rotate_right),
          ),
          IconButton(
            onPressed: () {
              ref.watch(controlProvider.notifier).toggleCameraStream();
            },
            icon: Icon(
                control.isCameraStreamStarted ? Icons.stop : Icons.play_arrow),
          ),
          IconButton(
            onPressed: () {
              ref.watch(clientProvider.notifier).reconnect();
            },
            icon: const Icon(Icons.refresh),
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
      ),
    );
  }

  void cameraStreamHandler(CameraImage image) {
    const handler = IsolateHandler.cnvrtCMRToGrayscaleByte;
    if (ref.watch(isolateFlagProvider)) return;
    ref.watch(isolateFlagProvider.notifier).state = true;
    Future.delayed(
      Duration(milliseconds: 30),
      () {
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
      },
    ).then((value) {
      ref.watch(isolateFlagProvider.notifier).state = false;
    });
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
}
