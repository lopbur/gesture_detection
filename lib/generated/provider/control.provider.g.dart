// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../provider/control.provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Control _$$_ControlFromJson(Map<String, dynamic> json) => _$_Control(
      frameInterval: json['frameInterval'] as int? ?? 16,
      makeSequenceTime: json['makeSequenceTime'] as int? ?? 3,
      isCameraRotate: json['isCameraRotate'] as bool? ?? false,
      isCameraStreamStarted: json['isCameraStreamStarted'] as bool? ?? false,
      rotateAngle: json['rotateAngle'] as int? ?? 0,
    );

Map<String, dynamic> _$$_ControlToJson(_$_Control instance) =>
    <String, dynamic>{
      'frameInterval': instance.frameInterval,
      'makeSequenceTime': instance.makeSequenceTime,
      'isCameraRotate': instance.isCameraRotate,
      'isCameraStreamStarted': instance.isCameraStreamStarted,
      'rotateAngle': instance.rotateAngle,
    };
