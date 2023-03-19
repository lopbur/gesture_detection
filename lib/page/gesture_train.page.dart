import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';

import '../provider/client.provider.dart';
import '../provider/control.provider.dart';
import '../util/isolate_util.dart';

import 'widget/camera_preview_wrapper.dart';

class GestureTrainPage extends ConsumerStatefulWidget {
  const GestureTrainPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GestureTrainPageState();
}

class _GestureTrainPageState extends ConsumerState<GestureTrainPage> {
  final IsolateUtils _isolateUtils = IsolateUtils();

  @override
  void initState() {
    super.initState();
    _isolateUtils.initIsolate();

    Future.microtask(() => ref.watch(clientProvider.notifier).connect());
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
        title: const Text('Gesture Train'),
        actions: [
          IconButton(
            onPressed: () =>
                ref.watch(controlProvider.notifier).toggleCameraRotate(),
            icon: const Icon(Icons.rotate_right),
          ),
          IconButton(
            onPressed: () {
              makeSequence();
            },
            icon: Icon(
                control.isCameraStreamStarted ? Icons.stop : Icons.play_arrow),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CameraPreviewWrapper(
              streamHandler: cameraStreamHandler,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: 15,
                      itemBuilder: (BuildContext context, int index) => Card(
                        child: Center(child: Text('Dummy Card Text')),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void makeSequence() {
    ref.watch(controlProvider.notifier).setCameraStream(true);
    Future.delayed(
      Duration(seconds: ref.watch(controlProvider).makeSequenceTime),
      () => ref.watch(controlProvider.notifier).setCameraStream(false),
    );
  }

  void cameraStreamHandler(CameraImage image) {
    if (ref.watch(isolateFlagProvider)) return;
    ref.watch(isolateFlagProvider.notifier).state = true;
    Future.delayed(
        Duration(milliseconds: ref.watch(controlProvider).frameInterval), () {
      ref.watch(isolateFlagProvider.notifier).state = false;
    });
  }

  dynamic _isolateSpawn(CameraImage image) async {
    final responsePort = ReceivePort();

    _isolateUtils.sendMessage(
      isolateHandler,
      _isolateUtils.sendPort,
      responsePort,
      params: {'image': image},
    );
    final result = {
      'buffer': await responsePort.first,
      'height': image.height,
      'width': image.width
    };

    ref.watch(clientProvider.notifier).send(MessageType.requestStream, result);
  }

  static Future<dynamic> isolateHandler(dynamic params) async {
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
}
