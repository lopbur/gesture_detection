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
class ConfigDescription {
  final String alias;
  final List<dynamic> keyMap;

  @override
  bool ==operator(Object other){
    if (identical(this, other)) return true;
    return other.alias == alias && other.keymap == keymap;
  }

  @override
  int get hashCode => alias.hashCode ^ keymap.hashCode;
}

class Config extends StateNotifier<List<ConfigDescription>> {
  Config() : super([]);

  static final provider = StateNotifierProvider<Config, List<ConfigDescription>>((ref) => {
    return Config();
  })

  void addConfig(ConfigDescription newConfig) {
    state = [...state, newConfig];
  }

  void removeConfig(String alias) {
    state = state.removeWhere((e) => e.alias == alias);
  }

  void modifyConfig(ConfigDescription newConfig, String alias) {
    state = [
      for (final config in state)
        if (config.alias == alias) newConfig
        else config,
    ]
  }
}
