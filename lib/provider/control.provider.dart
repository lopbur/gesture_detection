import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class ControlDescription {
  final int activeCamera;
  final bool isCameraRotate;
  final bool isCameraStreamStarted;
  final bool isIsolateBusy;

  const ControlDescription({
    this.activeCamera = 0,
    this.isCameraRotate = false,
    this.isCameraStreamStarted = true,
    this.isIsolateBusy = false,
  });

  ControlDescription copyWith({
    int? activeCamera,
    bool? isCameraRotate,
    bool? isCameraStreamStarted,
    bool? isIsolateBusy,
  }) =>
      ControlDescription(
        activeCamera: activeCamera ?? this.activeCamera,
        isCameraRotate: isCameraRotate ?? this.isCameraRotate,
        isCameraStreamStarted:
            isCameraStreamStarted ?? this.isCameraStreamStarted,
        isIsolateBusy: isIsolateBusy ?? this.isIsolateBusy,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ControlDescription &&
        other.activeCamera == activeCamera &&
        other.isCameraRotate == isCameraRotate &&
        other.isCameraStreamStarted == isCameraStreamStarted &&
        other.isIsolateBusy == isIsolateBusy;
  }

  @override
  int get hashCode =>
      activeCamera.hashCode ^
      isCameraRotate.hashCode ^
      isCameraStreamStarted.hashCode ^
      isIsolateBusy.hashCode;
}

class Control extends StateNotifier<ControlDescription> {
  Control() : super(const ControlDescription());

  void setActiveCamera(int number) =>
      state = state.copyWith(activeCamera: number);

  void toggleCameraRotate() =>
      state = state.copyWith(isCameraRotate: !state.isCameraRotate);

  void toggleCameraStream() => state =
      state.copyWith(isCameraStreamStarted: !state.isCameraStreamStarted);

  void setIsolateBusy(bool isIsolateBusy) =>
      state = state.copyWith(isIsolateBusy: isIsolateBusy);
}

final controlProvider = StateNotifierProvider<Control, ControlDescription>(
  (ref) => Control(),
);
