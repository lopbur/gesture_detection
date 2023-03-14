import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class ControlDescription {
  final int activeCamera;
  final bool isCameraRotate;
  final bool isCameraStreamStarted;

  const ControlDescription(
      {this.activeCamera = 0,
      this.isCameraRotate = false,
      this.isCameraStreamStarted = true});

  ControlDescription copyWith({
    int? activeCamera,
    bool? isCameraRotate,
    bool? isCameraStreamStarted,
  }) =>
      ControlDescription(
        activeCamera: activeCamera ?? this.activeCamera,
        isCameraRotate: isCameraRotate ?? this.isCameraRotate,
        isCameraStreamStarted:
            isCameraStreamStarted ?? this.isCameraStreamStarted,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ControlDescription &&
        other.activeCamera == activeCamera &&
        other.isCameraRotate == isCameraRotate &&
        other.isCameraStreamStarted == isCameraStreamStarted;
  }

  @override
  int get hashCode =>
      activeCamera.hashCode ^
      isCameraRotate.hashCode ^
      isCameraStreamStarted.hashCode;
}

class Control extends StateNotifier<ControlDescription> {
  Control() : super(const ControlDescription());

  void setActiveCamera(int number) =>
      state = state.copyWith(activeCamera: number);

  void toggleCameraRotate() =>
      state = state.copyWith(isCameraRotate: !state.isCameraRotate);

  void toggleCameraStream() => state =
      state.copyWith(isCameraStreamStarted: !state.isCameraStreamStarted);
}

final controlProvider = StateNotifierProvider<Control, ControlDescription>(
  (ref) => Control(),
);
