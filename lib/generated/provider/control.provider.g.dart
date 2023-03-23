// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../provider/control.provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Control _$$_ControlFromJson(Map<String, dynamic> json) => _$_Control(
      frameInterval: json['frameInterval'] as int? ?? 16,
      rotateAngle: json['rotateAngle'] as int? ?? 0,
      isCameraFront: json['isCameraFront'] as bool? ?? false,
      isCameraStreamStarted: json['isCameraStreamStarted'] as bool? ?? false,
      makeSequenceTime: json['makeSequenceTime'] as int? ?? 3,
      showPreviewTrain: json['showPreviewTrain'] as bool? ?? false,
    );

Map<String, dynamic> _$$_ControlToJson(_$_Control instance) =>
    <String, dynamic>{
      'frameInterval': instance.frameInterval,
      'rotateAngle': instance.rotateAngle,
      'isCameraFront': instance.isCameraFront,
      'isCameraStreamStarted': instance.isCameraStreamStarted,
      'makeSequenceTime': instance.makeSequenceTime,
      'showPreviewTrain': instance.showPreviewTrain,
    };
