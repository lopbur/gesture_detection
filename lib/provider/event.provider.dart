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
class EventDetail {
  final String alias;
  final String gesture;
  final List<EventType> keyMap;

  const EventDetail(
      {this.alias = 'none', this.gesture = 'none', this.keyMap = const []});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventDetail &&
        other.alias == alias &&
        other.keyMap == keyMap;
  }

  @override
  int get hashCode => alias.hashCode ^ keyMap.hashCode;
}

class Event extends StateNotifier<List<EventDetail>> {
  Event() : super([]);

  void addConfig() {
    state = [...state, EventDetail(alias: 'My gesture ${state.length}')];
  }

  void removeConfig(String alias) {
    state = [
      for (final config in state)
        if (config.alias != alias) config,
    ];
  }

  void modifyConfig(EventDetail newConfig, String alias) {
    state = [
      for (final config in state)
        if (config.alias == alias) newConfig else config,
    ];
  }
}

final eventProvider = StateNotifierProvider<Event, List<EventDetail>>((ref) {
  return Event();
});
