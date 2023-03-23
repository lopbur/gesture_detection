import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

//use Uint8ListConverter
import '../util/converter.dart';

part '../generated/provider/train.provider.freezed.dart';
part '../generated/provider/train.provider.g.dart';

int previewImageIndex = 0;
final previewImageIndexProvider = StateProvider<int>(
  (ref) {
    return previewImageIndex;
  },
);

@freezed
class TrainSet with _$TrainSet {
  factory TrainSet({
    @Uint8ListConverter() @Default([]) List<Uint8List> planes,
    @Default('YUV420') String format,
    @Default('My gesture') String label,
  }) = _TrainSet;

  factory TrainSet.fromJson(Map<String, dynamic> json) =>
      _$TrainSetFromJson(json);
}

class TrainSetProvider extends StateNotifier<TrainSet> {
  TrainSetProvider() : super(TrainSet());

  void add(Uint8List plane) {
    state = state.copyWith(planes: [...state.planes, plane]);
  }

  void update(List<Uint8List> newPlanes) {
    state = state.copyWith(planes: newPlanes);
  }

  void removeAll() {
    state = state.copyWith(planes: []);
  }

  void setLabel(String newLabel) {
    state = state.copyWith(label: newLabel);
  }

  // it should change to use enum
  void setFormat(String newFormat) {
    state = state.copyWith(format: newFormat);
  }
}

final trainSetProvider = StateNotifierProvider<TrainSetProvider, TrainSet>(
  (ref) => TrainSetProvider(),
);
