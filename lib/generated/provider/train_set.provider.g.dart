// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../provider/train_set.provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_TrainSet _$$_TrainSetFromJson(Map<String, dynamic> json) => _$_TrainSet(
      train: (json['train'] as List<dynamic>?)
              ?.map((e) => const Uint8ListConverter().fromJson(e as Object))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$_TrainSetToJson(_$_TrainSet instance) =>
    <String, dynamic>{
      'train': instance.train.map(const Uint8ListConverter().toJson).toList(),
    };
