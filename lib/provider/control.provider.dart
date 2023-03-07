import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class Control {
  final int activeCamera;
  final bool isCameraRotate;

  const Control({this.activeCamera = 0, this.isCameraRotate = false});

  Control copyWith({
    int? activeCamera,
    bool? isCameraRotate,
  }) =>
      Control(
        activeCamera: activeCamera ?? this.activeCamera,
        isCameraRotate: isCameraRotate ?? this.isCameraRotate,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Control &&
        other.activeCamera == activeCamera &&
        other.isCameraRotate == isCameraRotate;
  }

  @override
  int get hashCode => activeCamera.hashCode ^ isCameraRotate.hashCode;
}

class ControlNotifier extends StateNotifier<Control> {
  ControlNotifier() : super(const Control());

  void setActiveCamera(int number) =>
      state = state.copyWith(activeCamera: number);

  void toggleCameraRotate() =>
      state = state.copyWith(isCameraRotate: !state.isCameraRotate);
}

// final controlProvider = Provider<Control>(((ref) => Control()));
final controlProvider = StateNotifierProvider<ControlNotifier, Control>(
  (ref) => ControlNotifier(),
);
