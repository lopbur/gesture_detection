import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum EventType {
  m1('m1', 'Left'),
  m2('m2', 'Right'),
  m3('m3', 'Middle'),
  m4('m4', 'Side 4'),
  m5('m5', 'Side 5'),
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

  const EventType(this.function, this.alias);
  final String function;
  final String alias;

  factory EventType.getByFunction(String function) =>
      EventType.values.firstWhere((element) => element.function == function,
          orElse: () => EventType.undefined);

  factory EventType.getByAlias(String alias) =>
      EventType.values.firstWhere((element) => element.alias == alias,
          orElse: () => EventType.undefined);
}

@immutable
class ConfigDescription {
  final String alias;
  final String gesture;
  final List<EventType> keyMap;

  const ConfigDescription(
      {this.alias = '', this.gesture = '', this.keyMap = const []});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConfigDescription &&
        other.alias == alias &&
        other.keyMap == keyMap;
  }

  @override
  int get hashCode => alias.hashCode ^ keyMap.hashCode;
}

// it might be better when use provider famliy of configdescription class instead managing list of each class model?
// class Config extends StateNotifier<List<ConfigDescription>> {
//   Config() : super([]);

//   static final provider =
//       StateNotifierProvider<Config, List<ConfigDescription>>((ref) {
//     return Config();
//   });

//   void addConfig(ConfigDescription newConfig) {
//     state = [...state, newConfig];
//   }

//   void removeConfig(String alias) {
//     state = [
//       for (final config in state)
//         if (config.alias != alias) config,
//     ];
//   }

//   void modifyConfig(ConfigDescription newConfig, String alias) {
//     state = [
//       for (final config in state)
//         if (config.alias == alias) newConfig else config,
//     ];
//   }
// }
