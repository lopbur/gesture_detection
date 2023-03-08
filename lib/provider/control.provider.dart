import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MouseEvent {
  m1('m1', 'Left'),
  m2('m2', 'Right'),
  m3('m3', 'Middle'),
  m4('m4', 'Side 4'),
  m5('m5', 'Side 5'),
  undefined('undefined', 'undefined');

  const MouseEvent(this.function, this.alias);
  final String function;
  final String alias;

  factory MouseEvent.getByFunction(String function) =>
      MouseEvent.values.firstWhere((element) => element.function == function,
          orElse: () => MouseEvent.undefined);

  factory MouseEvent.getByAlias(String alias) =>
      MouseEvent.values.firstWhere((element) => element.alias == alias,
          orElse: () => MouseEvent.undefined);
}

enum SpecialKey {
  tab('tab', 'Tab'),
  shift('shift', 'Shift'),
  alt('alt', 'Alt'),
  ctrl('ctrl', 'Ctrl'),
  enter('enter', 'Enter'),
  space('space', 'Space'),
  backspace('backspace', 'Backspace'),
  escape('escape', 'ESC'),
  caps('caps', 'Caps Lock'),
  scrLk('scrLk', 'Scroll Lock'),
  numLk('numLk', 'Num Lock'),
  undefined('undefined', 'undefined');

  const SpecialKey(this.function, this.alias);
  final String function;
  final String alias;

  factory SpecialKey.getByFunction(String function) =>
      SpecialKey.values.firstWhere((element) => element.function == function,
          orElse: () => SpecialKey.undefined);

  factory SpecialKey.getByAlias(String alias) =>
      SpecialKey.values.firstWhere((element) => element.alias == alias,
          orElse: () => SpecialKey.undefined);
}

@immutable
class GestureDescription {}

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
