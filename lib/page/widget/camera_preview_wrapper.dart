import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gesture_detection_rebuild/provider/control.provider.dart';

typedef CameraImageStreamCallBack = void Function(CameraImage);

class CameraPreviewWrapper extends ConsumerStatefulWidget {
  CameraPreviewWrapper({
    super.key,
    CameraImageStreamCallBack? streamHandler,
  }) : streamHandler = streamHandler ?? ((image) {});
  final CameraImageStreamCallBack streamHandler;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CameraPreviewWrapperState();
}

class _CameraPreviewWrapperState extends ConsumerState<CameraPreviewWrapper> {
  CameraController? _controller;
  late List<CameraDescription> _cameras;

  @override
  void initState() {
    super.initState();

    initSync();
  }

  void initSync() async {
    _cameras = await availableCameras();
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
    super.dispose();
  }

  void _stopCameraStream() {
    if (!mounted) return;
    if ((_controller?.value.isStreamingImages ?? false)) {
      _controller!.stopImageStream();
    }
  }

  void _startCameraStream() async {
    if (!mounted) return;
    if (!(_controller?.value.isStreamingImages ?? true)) {
      _controller!.startImageStream(widget.streamHandler);
    }
  }

  @override
  Widget build(BuildContext context) {
    final control = ref.watch(controlProvider);

    control.isCameraStreamStarted ? _startCameraStream() : _stopCameraStream();

    return (_controller?.value.isInitialized ?? false)
        ? ModelCameraPreview(cameraController: _controller!)
        : Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}

class ModelCameraPreview extends ConsumerWidget {
  const ModelCameraPreview({super.key, required this.cameraController});
  final CameraController cameraController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Control control = ref.watch(controlProvider);

    final widgetSize = MediaQuery.of(context).size;
    final scale =
        1 / (cameraController.value.aspectRatio * widgetSize.aspectRatio) +
            0.05;

    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Center(
        child: Stack(
          children: [
            Transform.rotate(
              angle: (control.isCameraRotate ? -90 : 0) * math.pi / 180,
              child: Transform.scale(
                scale: scale,
                child: CameraPreview(cameraController),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
