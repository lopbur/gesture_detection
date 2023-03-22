import 'dart:isolate';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:gesture_detection/util/converter.dart';

import '../provider/client.provider.dart';
import '../provider/control.provider.dart';
import '../provider/train.provider.dart';
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

  final testList = <Widget>[];

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
                      itemCount: ref.watch(trainSetProvider).planes.length,
                      itemBuilder: (BuildContext context, int index) => Card(
                        child: Center(
                          child: Image.memory(
                              ref.watch(trainSetProvider).planes[index]),
                        ),
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
      Duration(milliseconds: ref.watch(controlProvider).frameInterval),
      () {
        _isolateSpawn(image, {});
        ref.watch(isolateFlagProvider.notifier).state = false;
      },
    );
  }

  dynamic _isolateSpawn(
      CameraImage? image, Map<String, dynamic> runParameter) async {
    final responsePort = ReceivePort();

    Map params = {
      ...image != null ? {"image": image} : {},
      ...runParameter,
    };

    _isolateUtils.sendMessage(
      isolateHandler,
      _isolateUtils.sendPort,
      responsePort,
      params: params,
    );

    // ref.watch(trainSetProvider.notifier).add(await responsePort.first);
  }

  static Future<dynamic> isolateHandler(dynamic params) async {
    final image = params['image'] as CameraImage;
    // final byte = await ImageConverter.convertYUV420ToRGBByteList(image);
    final byte = await ImageConverter.convertYUV420ToRGB(image);
    print(byte);
    // final Image byteToImage = Image.memory(byte!);
    // print(byteToImage);
    return byte;
  }
}
