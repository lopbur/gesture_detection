// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../provider/gesture_train.provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_TrainSet _$$_TrainSetFromJson(Map<String, dynamic> json) => _$_TrainSet(
      planes: (json['planes'] as List<dynamic>?)
              ?.map((e) => const Uint8ListConverter().fromJson(e as Object))
              .toList() ??
          const [],
      format: json['format'] as String? ?? 'YUV420',
      label: json['label'] as String? ?? 'My gesture',
    );

Map<String, dynamic> _$$_TrainSetToJson(_$_TrainSet instance) =>
    <String, dynamic>{
      'planes': instance.planes.map(const Uint8ListConverter().toJson).toList(),
      'format': instance.format,
      'label': instance.label,
    };
