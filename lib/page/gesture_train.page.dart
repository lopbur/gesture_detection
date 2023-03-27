import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gesture_detection/page/widget/image_sequence.dart';
import 'package:gesture_detection/provider/handler.provider.dart';

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
                                  return train.planes.isEmpty
                                      ? const Text('Train set is empty.')
                                      : const ImageSequence();
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
                      ref.watch(controlProvider.notifier).toggleCameraStream();
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
                          .setCameraStream(false);
                      ref.watch(trainSetProvider.notifier).removeAll();
                    },
                    child: const Icon(
                      Icons.highlight_remove_sharp,
                    ),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      sendImageSequenceHandler();
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
    Future.delayed(
      Duration(seconds: ref.watch(controlProvider).makeSequenceTime),
      () => ref.watch(controlProvider.notifier).setCameraStream(false),
    );
  }

  void cameraStreamHandler(CameraImage image) {
    final handler = ref.watch(handlerProvider)['isolate_cvCMRToRGB'];
    if (handler == null) return;

    Future.delayed(
      Duration(milliseconds: ref.watch(controlProvider).frameInterval),
      () {
        _isolateSpawn(
          handler,
          {'image': image},
          (result) {
            if (ref.watch(controlProvider).isCameraStreamStarted) {
              if (result != null) {
                return ref.watch(trainSetProvider.notifier).add(result);
              }
            }
          },
        );
        ref.watch(isolateFlagProvider.notifier).state = false;
      },
    );
  }

  void sendImageSequenceHandler() {
    final handler = ref.watch(handlerProvider)['isolate_cvIMGSeqToByte'];
    if (handler == null) return;

    _isolateSpawn(
      handler,
      {'list': ref.watch(trainSetProvider).planes},
      (result) {
        const int chunkSize = 100 * 1024; // 100KB chunk size (adjust as needed)

        int offset = 0;
        Uint8List data = result;

        while (offset < data.length) {
          final int remaining = data.length - offset;
          final int chunkLength = remaining > chunkSize ? chunkSize : remaining;
          final Uint8List chunk = Uint8List.view(
            data.buffer,
            offset,
            chunkLength,
          );
          offset += chunkLength;

          final bool isLastChunk = (offset == data.length);
          // send the chunk to the server
          // socket.emit('imageChunk', chunk);
          ref.watch(clientProvider.notifier).send(MessageType.registerGesture,
              {'data': chunk, 'isLastChunk': isLastChunk});
        }
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
}
