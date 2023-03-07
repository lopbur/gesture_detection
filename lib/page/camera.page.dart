import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:socket_io_client/socket_io_client.dart';

import 'widget/modelCameraPrevide.widget.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  final Socket socket = io(
    'http://10.0.2.2:5000',
    OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
  );

  CameraController? _controller;
  late List<CameraDescription> _cameras;
  bool isCameraRotate = false;

  @override
  void initState() {
    super.initState();

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
            isCameraRotate: isCameraRotate,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gesture_detection'),
        // actions: [
        //   IconButton(
        //     onPressed: _imageStreamToggle,
        //     icon:
        //         _isRun ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
        //   ),
        //   IconButton(
        //     onPressed: () => _navigateAndDisplaySelection(context),
        //     icon: const Icon(Icons.settings),
        //   ),
        // ],
      ),
      body: getCameraPreviewWidget(),
    );
  }
}
