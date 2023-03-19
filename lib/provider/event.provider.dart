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

final eventProvider =
    StateNotifierProvider<EventSettingList, List<EventSetting>>(
        (ref) => EventSettingList());

@immutable
class EventSetting {
  final String alias;
  final String gesture;
  final List<EventType> keyMap;

  const EventSetting(
      {this.alias = 'none', this.gesture = 'none', this.keyMap = const []});

  EventSetting copyWith({
    String? alias,
    String? gesture,
    List<EventType>? keyMap,
  }) =>
      EventSetting(
        alias: alias ?? this.alias,
        gesture: gesture ?? this.gesture,
        keyMap: keyMap ?? this.keyMap,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventSetting &&
        other.alias == alias &&
        other.keyMap == keyMap;
  }

  @override
  int get hashCode => alias.hashCode ^ keyMap.hashCode;
}

class EventSettingList extends StateNotifier<List<EventSetting>> {
  EventSettingList() : super([]);

  void add(EventSetting eventSetting) {
    state = [
      ...state,
      eventSetting,
    ];
  }

  void addEmpty() {
    state = [
      ...state,
      EventSetting(alias: 'My Gesture ${state.length}'),
    ];
  }

  void remove(EventSetting eventSetting) {
    state = state.where((e) => e != eventSetting).toList();
  }

  void update(EventSetting oldEventSetting, EventSetting newEventSetting) {
    final index =
        state.indexWhere((event) => event.alias == oldEventSetting.alias);
    if (index != -1) {
      state = [
        ...state.sublist(0, index),
        newEventSetting,
        ...state.sublist(index + 1),
      ];
    }
  }

  void addKeyMapEmpty(String eventAlias) {
    final index = state.indexWhere((event) => event.alias == eventAlias);
    if (index != -1) {
      final eventSetting = state[index];
      final updatedEventSetting = eventSetting
          .copyWith(keyMap: [...eventSetting.keyMap, EventType.undefined]);

      update(eventSetting, updatedEventSetting);
    }
  }

  void updateKeyMap(String eventAlias, List<EventType> newKeyMap) {
    final index = state.indexWhere((event) => event.alias == eventAlias);
    if (index != -1) {
      final eventSetting = state[index];
      final updatedEventSetting = eventSetting.copyWith(keyMap: newKeyMap);

      update(eventSetting, updatedEventSetting);
    }
  }

  void updateKeyMapWhere(String eventAlias, int targetIndex, EventType newKey) {
    final index = state.indexWhere((event) => event.alias == eventAlias);
    if (index != -1) {
      final eventSetting = state[index];
      if (targetIndex >= 0 && targetIndex < eventSetting.keyMap.length) {
        final updatedKeyMap = [
          ...eventSetting.keyMap.sublist(0, targetIndex),
          newKey,
          ...eventSetting.keyMap.sublist(targetIndex + 1),
        ];
        updateKeyMap(eventAlias, updatedKeyMap);
      }
    }
  }

  void removeKeyMapWhere(String eventAlias, int targetIndex) {
    final index = state.indexWhere((event) => event.alias == eventAlias);
    if (index != -1) {
      final eventSetting = state[index];
      final updatedKeyMap = List<EventType>.from(eventSetting.keyMap);
      if (targetIndex >= 0 && targetIndex < updatedKeyMap.length) {
        updatedKeyMap.removeAt(targetIndex);
        updateKeyMap(eventAlias, updatedKeyMap);
      }
    }
  }
}
