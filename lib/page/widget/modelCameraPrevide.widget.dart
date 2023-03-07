import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModelCameraPreview extends ConsumerWidget {
  const ModelCameraPreview(
      {super.key,
      required this.cameraController,
      required this.isCameraRotate});
  final CameraController cameraController;
  final bool isCameraRotate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final widgetSize = MediaQuery.of(context).size;
    final scale =
        1 / (cameraController.value.aspectRatio * widgetSize.aspectRatio);

    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Center(
        child: Stack(
          children: [
            Transform.rotate(
              angle: (isCameraRotate ? -90 : 0) * math.pi / 180,
              child: Transform.scale(
                scale: scale,
                child: CameraPreview(cameraController),
              ),
            ),
            Text(isCameraRotate ? 'True' : 'False'),
          ],
        ),
      ),
    );
  }
}
