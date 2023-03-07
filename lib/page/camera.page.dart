import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//import Providers
import 'package:gesture_detection_rebuild/provider/control.provider.dart';

import 'widget/modelCameraPrevide.widget.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  CameraController? _controller;
  late List<CameraDescription> _cameras;

  @override
  void initState() {
    super.initState();

    ref.read(controlProvider);

    initCamera();
  }

  void initCamera() async {
    _cameras = await availableCameras();

    _controller = CameraController(
      _cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize().then((value) {
      setState(() {});
      _startCameraStream;
    });
  }

  void _startCameraStream() async {
    if (!mounted) return;
    _controller!.startImageStream((CameraImage cameraImage) async {});
  }

  void _stopCameraStream() {
    if (!mounted) return;
    _controller!.stopImageStream();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gesture Detection'),
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(controlProvider.notifier).toggleCameraRotate(),
            icon: const Icon(Icons.rotate_right),
          ),
        ],
      ),
      body: getCameraPreviewWidget(),
    );
  }
}
