import 'dart:async';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gesture_detection_rebuild/provider/client.provider.dart';

import 'package:gesture_detection_rebuild/provider/control.provider.dart';

import '../util/isolate_util.dart';
import 'widget/modelCameraPrevide.widget.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  CameraController? _controller;
  late List<CameraDescription> _cameras;

  final int _frameInterval = (1000 / 50).floor();
  Timer? _frameTimer;

  final IsolateUtils _isolateUtils = IsolateUtils();

  @override
  void initState() {
    super.initState();
    Future.delayed(
        Duration.zero, () => ref.read(clientProvider.notifier).connect());
    initAsync();
  }

  //need provider about camera state
  void initAsync() async {
    _cameras = await availableCameras();
    _isolateUtils.initIsolate();

    _controller = CameraController(
      _cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize().then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller!.dispose();
    _isolateUtils.dispose();
    super.dispose();
  }

  void _stopCameraStream() {
    if (!mounted) return;
    if (_controller!.value.isStreamingImages) {
      _controller!.stopImageStream();
    }
  }

  void _startCameraStream() async {
    if (!mounted) return;
    _controller!.startImageStream((CameraImage image) {
      if (ref.read(controlProvider).isIsolateBusy) return;
      ref.read(controlProvider.notifier).setIsolateBusy(true);
      Future.delayed(Duration(milliseconds: _frameInterval), () {
        _isolateSpawn(image);
        ref.read(controlProvider.notifier).setIsolateBusy(false);
      });
    });
  }

  Widget getCameraPreviewWidget() {
    return _controller == null || !_controller!.value.isInitialized
        ? Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : ModelCameraPreview(
            cameraController: _controller!,
          );
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
                  ref.read(controlProvider.notifier).toggleCameraRotate(),
              icon: const Icon(Icons.rotate_right),
            ),
            IconButton(
              onPressed: () {
                ref.read(controlProvider.notifier).toggleCameraStream();
                control.isCameraStreamStarted
                    ? _startCameraStream()
                    : _stopCameraStream();
              },
              icon: Icon(control.isCameraStreamStarted
                  ? Icons.play_arrow
                  : Icons.stop),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: getCameraPreviewWidget(),
            ),
            Expanded(flex: 1, child: Container())
          ],
        ));
  }

  dynamic _isolateSpawn(CameraImage image) async {
    final responsePort = ReceivePort();

    _isolateUtils.sendMessage(
      handler,
      _isolateUtils.sendPort,
      responsePort,
      params: {'image': image},
    );
    final result = {
      'buffer': await responsePort.first,
      'height': image.height,
      'width': image.width
    };

    ref.read(clientProvider.notifier).send(MessageType.requestStream, result);
  }

  static Future<dynamic> handler(dynamic params) async {
    final data = params['image'] as CameraImage;
    final result = Uint8List(
        data.planes.fold(0, (count, plane) => count + plane.bytes.length));
    int offset = 0;
    for (final plane in data.planes) {
      result.setRange(offset, offset + plane.bytes.length, plane.bytes);
      offset += plane.bytes.length;
    }

    print(result);

    return result;
  }
}
