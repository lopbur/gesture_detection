import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class ControlDescription {
  final int activeCamera;
  final bool isCameraRotate;

  const ControlDescription(
      {this.activeCamera = 0, this.isCameraRotate = false});

  ControlDescription copyWith({
    int? activeCamera,
    bool? isCameraRotate,
  }) =>
      ControlDescription(
        activeCamera: activeCamera ?? this.activeCamera,
        isCameraRotate: isCameraRotate ?? this.isCameraRotate,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ControlDescription &&
        other.activeCamera == activeCamera &&
        other.isCameraRotate == isCameraRotate;
  }

  @override
  int get hashCode => activeCamera.hashCode ^ isCameraRotate.hashCode;
}

class Control extends StateNotifier<ControlDescription> {
  Control() : super(const ControlDescription());

  static final provider = StateNotifierProvider<Control, ControlDescription>(
    (ref) => Control(),
  );

  void setActiveCamera(int number) =>
      state = state.copyWith(activeCamera: number);

  void toggleCameraRotate() =>
      state = state.copyWith(isCameraRotate: !state.isCameraRotate);
}

//it might be better which is define provider as static methods on its own class
// final controlProvider = StateNotifierProvider<ControlNotifier, Control>(
//   (ref) => ControlNotifier(),
// );
