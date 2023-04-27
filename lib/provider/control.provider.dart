import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part '../generated/provider/control.provider.freezed.dart';
part '../generated/provider/control.provider.g.dart';

bool isIsolateBusy = false;
final isolateFlagProvider = StateProvider<bool>(
  (ref) => isIsolateBusy,
);

@freezed
class Control with _$Control {
  factory Control({
    // global control about camera_preview_wrapper
    @Default(100000) int frameInterval, // get image per frame
    @Default(0) int rotateAngle, // camera preview angle, clockwise
    @Default(false) bool isCameraFront, // camera position
    @Default(false) bool isCameraStreamStarted, // camera stream flag
    // gesture_train.page
    @Default(5) int makeSequenceTime, // user start make train set flag
  }) = _Control;

  factory Control.fromJson(Map<String, dynamic> json) =>
      _$ControlFromJson(json);
}

class ControlProvider extends StateNotifier<Control> {
  ControlProvider() : super(Control());

  void setFPS(int fps) {
    state = state.copyWith(frameInterval: (1000 / fps).floor());
  }

  void rotateCamera() {
    int angle = state.rotateAngle;
    angle = (angle + 90) >= 360 ? 0 : angle + 90;
    state = state.copyWith(rotateAngle: angle);
  }

  void toggleCameraFront() {
    state = state.copyWith(isCameraFront: !state.isCameraFront);
  }

  void toggleCameraStream() {
    state = state.copyWith(isCameraStreamStarted: !state.isCameraStreamStarted);
  }

  void setCameraStream(bool val) {
    state = state.copyWith(isCameraStreamStarted: val);
  }

  void setMakeSequenceTime(int val) {
    state = state.copyWith(makeSequenceTime: val);
  }
}

final controlProvider = StateNotifierProvider<ControlProvider, Control>(
  (ref) => ControlProvider(),
);
