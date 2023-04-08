import 'dart:async';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gesture_detection/util/isolate_handler.dart';

import '../provider/client.provider.dart';
import '../provider/control.provider.dart';
import '../provider/gesture_train.provider.dart';
import '../util/isolate_util.dart';

import 'widget/camera_preview_wrapper.dart';
import 'widget/image_sequence.dart';

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
                              child: Stack(
                                children: [
                                  Image.memory(
                                    train.planes[index],
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: InkWell(
                                      onTap: () {
                                        ref
                                            .watch(trainSetProvider.notifier)
                                            .removeWhere(index);
                                      },
                                      child: const Icon(
                                        Icons.clear,
                                        color: Colors.red,
                                        size: 30,
                                      ),
                                    ),
                                  )
                                ],
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
                          builder: (context) => Dialog(
                            child: Consumer(
                              builder: (context, ref, child) {
                                return train.planes.isEmpty
                                    ? const Text('Train set is empty.')
                                    : const ImageSequence();
                              },
                            ),
                          ),
                        );
                      }
                    },
                    child: const Icon(Icons.image),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      ref.watch(controlProvider.notifier).toggleCameraStream();
                      Future.delayed(
                        Duration(
                            seconds:
                                ref.watch(controlProvider).makeSequenceTime),
                        () => ref
                            .watch(controlProvider.notifier)
                            .setCameraStream(false),
                      );
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
                      String message = 'Send training data successfully.';
                      if (ref.watch(trainSetProvider).planes.isNotEmpty) {
                        final TextEditingController textFieldController =
                            TextEditingController();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Write gesture label.'),
                            content: TextField(
                              onChanged: (value) {
                                ref
                                    .watch(trainSetProvider.notifier)
                                    .setLabel(value);
                              },
                              controller: textFieldController,
                              decoration: const InputDecoration(
                                  hintText: "Text Field in Dialog"),
                            ),
                            actions: <Widget>[
                              MaterialButton(
                                color: Colors.red,
                                textColor: Colors.white,
                                child: const Text('CANCEL'),
                                onPressed: () {
                                  ref
                                      .watch(trainSetProvider.notifier)
                                      .setLabel('');
                                  Navigator.pop(context);
                                },
                              ),
                              MaterialButton(
                                color: Colors.green,
                                textColor: Colors.white,
                                child: const Text('OK'),
                                onPressed: () {
                                  sendImageSequenceHandler();
                                  showSnackBar(context, message);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      } else {
                        message = 'Training data is empty!';
                        showSnackBar(context, message);
                      }
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

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  //do capture camera stream to make train set sequences.
  void makeSequence() {
    Future.delayed(
      Duration(seconds: ref.watch(controlProvider).makeSequenceTime),
      () => ref.watch(controlProvider.notifier).setCameraStream(false),
    );
  }

  void cameraStreamHandler(CameraImage image) {
    const handler = IsolateHandler.cnvrtCMRToRGB;

    Future.delayed(
      Duration(milliseconds: ref.watch(controlProvider).frameInterval),
      () {
        if (ref.watch(isolateFlagProvider)) return;
        ref.watch(isolateFlagProvider.notifier).state = true;

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
    // final handler = ref.watch(handlerProvider)['isolate_cvIMGSeqToByte'];
    // if (handler == null) return;
    const handler = IsolateHandler.cnvrtIMGSeqToByte;

    _isolateSpawn(
      handler,
      {'list': ref.watch(trainSetProvider).planes},
      (result) {
        ref.watch(clientProvider.notifier).sendByteChunk(
          MessageType.registerGesture,
          result,
          100 * 1024,
          {'label': ref.watch(trainSetProvider).label},
        );
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
