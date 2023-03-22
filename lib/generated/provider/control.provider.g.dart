// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../provider/control.provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Control _$$_ControlFromJson(Map<String, dynamic> json) => _$_Control(
      frameInterval: json['frameInterval'] as int? ?? 16,
      makeSequenceTime: json['makeSequenceTime'] as int? ?? 3,
      rotateAngle: json['rotateAngle'] as int? ?? 0,
      isCameraFront: json['isCameraFront'] as bool? ?? false,
      isCameraStreamStarted: json['isCameraStreamStarted'] as bool? ?? false,
    );

Map<String, dynamic> _$$_ControlToJson(_$_Control instance) =>
    <String, dynamic>{
      'frameInterval': instance.frameInterval,
      'makeSequenceTime': instance.makeSequenceTime,
      'rotateAngle': instance.rotateAngle,
      'isCameraFront': instance.isCameraFront,
      'isCameraStreamStarted': instance.isCameraStreamStarted,
    };
