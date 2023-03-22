import 'dart:isolate';

import 'package:flutter/material.dart';
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
                ref.watch(controlProvider.notifier).toggleCameraFront(),
            icon: const Icon(Icons.flip),
          ),
          IconButton(
            onPressed: () => ref.watch(controlProvider.notifier).rotateCamera(),
            icon: const Icon(Icons.rotate_right),
          ),
          IconButton(
            onPressed: () {
              ref.watch(trainSetProvider.notifier).removeAll();
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
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: CameraPreviewWrapper(
                streamHandler: cameraStreamHandler,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Card(
                      color: Colors.blueGrey.shade300,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: ref.watch(trainSetProvider).planes.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.memory(
                              ref.watch(trainSetProvider).planes[index],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      ref.watch(trainSetProvider.notifier).removeAll();
                      makeSequence();
                    },
                    child: Icon(control.isCameraStreamStarted
                        ? Icons.stop
                        : Icons.play_arrow),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      ref.watch(trainSetProvider.notifier).removeAll();
                      makeSequence();
                    },
                    child: Icon(control.isCameraStreamStarted
                        ? Icons.stop
                        : Icons.play_arrow),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      ref.watch(trainSetProvider.notifier).removeAll();
                      makeSequence();
                    },
                    child: Icon(control.isCameraStreamStarted
                        ? Icons.stop
                        : Icons.play_arrow),
                  ),
                ],
              ),
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
    // testWidget = await responsePort.first;
    ref.watch(trainSetProvider.notifier).add(await responsePort.first);
  }

  static Future<dynamic> isolateHandler(dynamic params) async {
    final image = params['image'] as CameraImage;
    final byte = await ImageConverter.convertYUV420ToRGBByte(image);
    return byte;
  }
}
