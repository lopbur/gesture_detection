import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gesture_detection/provider/train.provider.dart';

class ImageSequence extends ConsumerStatefulWidget {
  const ImageSequence({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ImageSequenceState();
}

class _ImageSequenceState extends ConsumerState<ImageSequence> {
  Timer? previewImageTimer;

  @override
  void initState() {
    super.initState();

    Future.microtask(() => _startAnimation());
  }

  @override
  void dispose() {
    previewImageTimer?.cancel();
    previewImageTimer = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rawPlanes = ref.watch(trainSetProvider).planes;
    final currentImageIndex = ref.watch(previewImageIndexProvider);
    return rawPlanes.length >= currentImageIndex
        ? Image.memory(
            rawPlanes[currentImageIndex],
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) {
                return child;
              } else {
                return const LinearProgressIndicator();
              }
            },
          )
        : const LinearProgressIndicator();
  }

  void _startAnimation() {
    ref.watch(previewImageIndexProvider.notifier).state = 0;

    previewImageTimer = Timer.periodic(
      const Duration(milliseconds: 16),
      (timer) {
        final rawPlanes = ref.watch(trainSetProvider).planes;
        final currentImageIndex = ref.watch(previewImageIndexProvider);
        ref.watch(previewImageIndexProvider.notifier).state =
            (currentImageIndex + 1) % rawPlanes.length;
      },
    );
  }
}
