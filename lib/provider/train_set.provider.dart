import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../util/converter.dart';

part '../generated/provider/train_set.provider.freezed.dart';
part '../generated/provider/train_set.provider.g.dart';

@freezed
class TrainSet with _$TrainSet {
  factory TrainSet({
    @Uint8ListConverter() @Default([]) List<Uint8List> train,
  }) = _TrainSet;

  factory TrainSet.fromJson(Map<String, dynamic> json) =>
      _$TrainSetFromJson(json);
}

@freezed
class TrainSetPreview with _$TrainSetPreview {
  factory TrainSetPreview({
    @Default([]) List<CameraImage> trainPreview,
    @Default('New Gesture') String label,
  }) = _TrainSetPreview;
}

class TrainSetPreviewProvider extends StateNotifier<TrainSetPreview> {
  TrainSetPreviewProvider() : super(TrainSetPreview());

  void updateTrain(List<CameraImage> newTrain) {
    state = state.copyWith(trainPreview: newTrain);
  }

  void removeAllTrain() {
    state = state.copyWith(trainPreview: []);
  }

  void setLabel(String newLabel) {
    state = state.copyWith(label: newLabel);
  }
}

final trainSetProvider = StateProvider<TrainSet>((ref) => TrainSet());

final trainSetPreviewProvider =
    StateNotifierProvider<TrainSetPreviewProvider, TrainSetPreview>(
  (ref) => TrainSetPreviewProvider(),
);
