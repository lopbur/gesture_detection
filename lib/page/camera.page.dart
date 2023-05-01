import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:gesture_detection/page/widget/hand_landmark_painter.dart';
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
  final double imageRatio = 1.34;

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
    final landmarkOffset = ref.watch(landmarkOffsetProvider);

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
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                Text('$landmarkOffset'),
                _drawHands,
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget get _drawHands => _ModelPainter(
        customPainter: HandLandmarkPainter(
          points: ref.watch(landmarkOffsetProvider),
          ratio: imageRatio,
        ),
      );

  void cameraStreamHandler(CameraImage image) {
    const handler = IsolateHandler.cnvrtCMRToGrayscaleByte;
    if (ref.watch(isolateFlagProvider)) return;
    ref.watch(isolateFlagProvider.notifier).state = true;
    Future.delayed(
      const Duration(milliseconds: 30),
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

class _ModelPainter extends StatelessWidget {
  const _ModelPainter({
    required this.customPainter,
    Key? key,
  }) : super(key: key);

  final CustomPainter customPainter;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: customPainter,
    );
  }
}
