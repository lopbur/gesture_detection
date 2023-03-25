import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:gesture_detection/page/widget/image_sequence.dart';
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
    final train = ref.watch(trainSetProvider);

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
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRect(
                    clipBehavior: Clip.hardEdge,
                    child: CameraPreviewWrapper(
                      streamHandler: cameraStreamHandler,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: train.planes.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.memory(
                                train.planes[index],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 0,
            thickness: 2,
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      if (!control.isCameraStreamStarted) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: Consumer(
                                builder: (context, ref, child) {
                                  return const Card(
                                    child: ImageSequence(),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }
                    },
                    child: const Icon(Icons.image),
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
                      ref
                          .watch(controlProvider.notifier)
                          .setMakeSequenceTime(3);
                    },
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  //do capture camera stream to make train set sequences.
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
        _isolateSpawn(
          imageConvertIsolateHandler,
          {'image': image},
          (result) {
            return ref.watch(trainSetProvider.notifier).add(result);
          },
        );
        ref.watch(isolateFlagProvider.notifier).state = false;
      },
    );
  }

  dynamic _isolateSpawn(
      Future<dynamic> Function(dynamic) isolateHandler,
      Map<String, dynamic>? handlerParameter,
      void Function(dynamic) postCallback) async {
    final responsePort = ReceivePort();

    Map params = {
      ...handlerParameter ?? {},
    };

    _isolateUtils.sendMessage(
      isolateHandler,
      _isolateUtils.sendPort,
      responsePort,
      params: params,
    );

    postCallback(await responsePort.first);
  }

  static Future<dynamic> imageConvertIsolateHandler(dynamic params) async {
    final image = params['image'] as CameraImage;
    final byte = await ImageConverter.convertYUV420ToRGBByte(image);
    return byte;
  }

  static Future<dynamic> imageSequenceTransfortIsolateHandler(
    dynamic params,
  ) async {}
}
