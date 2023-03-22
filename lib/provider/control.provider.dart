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
    @Default(16) int frameInterval,
    @Default(3) int makeSequenceTime,
    @Default(false) bool isCameraRotate,
    @Default(false) bool isCameraStreamStarted,
    @Default(0) int rotateAngle,
  }) = _Control;

  factory Control.fromJson(Map<String, dynamic> json) =>
      _$ControlFromJson(json);
}

class ControlProvider extends StateNotifier<Control> {
  ControlProvider() : super(Control());

  void setFPS(int fps) {
    state = state.copyWith(frameInterval: (1000 / fps).floor());
  }

  void setCameraStream(bool val) {
    state = state.copyWith(isCameraStreamStarted: val);
  }

  void setMakeSequenceTime(int val) {
    state = state.copyWith(makeSequenceTime: val);
  }

  void toggleCameraRotate() {
    state = state.copyWith(isCameraRotate: !state.isCameraRotate);
  }

  void toggleCameraStream() {
    state = state.copyWith(isCameraStreamStarted: !state.isCameraStreamStarted);
  }

  void rotateCamera() {
    int angle = state.rotateAngle;
    angle = (angle + 90) >= 360 ? 0 : angle + 90;
    state = state.copyWith(rotateAngle: angle); 
  }
}

final controlProvider = StateNotifierProvider<ControlProvider, Control>(
  (ref) => ControlProvider(),
);
