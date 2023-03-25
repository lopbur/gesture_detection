import 'dart:developer';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../provider/control.provider.dart';

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
  late List<CameraDescription> _availableCameras;

  @override
  void initState() {
    super.initState();

    initSync();
  }

  void initSync() async {
    await _getAvailableCameras();
  }

  Future<void> _getAvailableCameras() async {
    _availableCameras = await availableCameras();
    await _initCamera(_availableCameras.first);
  }

  Future<void> _initCamera(CameraDescription description) async {
    _controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    try {
      await _controller!.initialize();
      setState(() {});
    } catch (e) {
      log('>>>>> Error has occured while initialized camera: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _stopCameraStream() {
    if (!mounted) return;
    if (!(_controller?.value.isStreamingImages ?? false)) return;
    _controller!.stopImageStream();
  }

  void _startCameraStream() async {
    if (!mounted) return;
    if (_controller?.value.isStreamingImages ?? true) return;
    _controller!.startImageStream(widget.streamHandler);
  }

  void _setCameraFront(bool c) async {
    if (!mounted) return;
    if (_controller?.value.isStreamingImages ?? true) return;
    final lensDirection =
        c ? CameraLensDirection.front : CameraLensDirection.back;
    if (_controller!.description.lensDirection != lensDirection) {
      final CameraDescription newDescription =
          _availableCameras.firstWhere((e) => e.lensDirection == lensDirection);
      await _initCamera(newDescription);
    }
  }

  @override
  Widget build(BuildContext context) {
    final control = ref.watch(controlProvider);

    control.isCameraStreamStarted ? _startCameraStream() : _stopCameraStream();
    _setCameraFront(control.isCameraFront);

    return _controller?.value.isInitialized ?? false
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
    final widgetSize = MediaQuery.of(context).size;
    final scale =
        1 / (cameraController.value.aspectRatio * widgetSize.aspectRatio) +
            0.05;

    return Container(
      color: Colors.grey,
      child: Center(
        child: Transform.rotate(
          angle: ref.watch(controlProvider).rotateAngle * math.pi / 180,
          child: Transform.scale(
            scale: scale,
            child: CameraPreview(cameraController),
          ),
        ),
      ),
    );
  }
}
