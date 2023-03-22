// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../provider/control.provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Control _$ControlFromJson(Map<String, dynamic> json) {
  return _Control.fromJson(json);
}

/// @nodoc
mixin _$Control {
  int get frameInterval => throw _privateConstructorUsedError;
  int get makeSequenceTime => throw _privateConstructorUsedError;
  bool get isCameraRotate => throw _privateConstructorUsedError;
  bool get isCameraStreamStarted => throw _privateConstructorUsedError;
  int get rotateAngle => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ControlCopyWith<Control> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ControlCopyWith<$Res> {
  factory $ControlCopyWith(Control value, $Res Function(Control) then) =
      _$ControlCopyWithImpl<$Res, Control>;
  @useResult
  $Res call(
      {int frameInterval,
      int makeSequenceTime,
      bool isCameraRotate,
      bool isCameraStreamStarted,
      int rotateAngle});
}

/// @nodoc
class _$ControlCopyWithImpl<$Res, $Val extends Control>
    implements $ControlCopyWith<$Res> {
  _$ControlCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frameInterval = null,
    Object? makeSequenceTime = null,
    Object? isCameraRotate = null,
    Object? isCameraStreamStarted = null,
    Object? rotateAngle = null,
  }) {
    return _then(_value.copyWith(
      frameInterval: null == frameInterval
          ? _value.frameInterval
          : frameInterval // ignore: cast_nullable_to_non_nullable
              as int,
      makeSequenceTime: null == makeSequenceTime
          ? _value.makeSequenceTime
          : makeSequenceTime // ignore: cast_nullable_to_non_nullable
              as int,
      isCameraRotate: null == isCameraRotate
          ? _value.isCameraRotate
          : isCameraRotate // ignore: cast_nullable_to_non_nullable
              as bool,
      isCameraStreamStarted: null == isCameraStreamStarted
          ? _value.isCameraStreamStarted
          : isCameraStreamStarted // ignore: cast_nullable_to_non_nullable
              as bool,
      rotateAngle: null == rotateAngle
          ? _value.rotateAngle
          : rotateAngle // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ControlCopyWith<$Res> implements $ControlCopyWith<$Res> {
  factory _$$_ControlCopyWith(
          _$_Control value, $Res Function(_$_Control) then) =
      __$$_ControlCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int frameInterval,
      int makeSequenceTime,
      bool isCameraRotate,
      bool isCameraStreamStarted,
      int rotateAngle});
}

/// @nodoc
class __$$_ControlCopyWithImpl<$Res>
    extends _$ControlCopyWithImpl<$Res, _$_Control>
    implements _$$_ControlCopyWith<$Res> {
  __$$_ControlCopyWithImpl(_$_Control _value, $Res Function(_$_Control) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frameInterval = null,
    Object? makeSequenceTime = null,
    Object? isCameraRotate = null,
    Object? isCameraStreamStarted = null,
    Object? rotateAngle = null,
  }) {
    return _then(_$_Control(
      frameInterval: null == frameInterval
          ? _value.frameInterval
          : frameInterval // ignore: cast_nullable_to_non_nullable
              as int,
      makeSequenceTime: null == makeSequenceTime
          ? _value.makeSequenceTime
          : makeSequenceTime // ignore: cast_nullable_to_non_nullable
              as int,
      isCameraRotate: null == isCameraRotate
          ? _value.isCameraRotate
          : isCameraRotate // ignore: cast_nullable_to_non_nullable
              as bool,
      isCameraStreamStarted: null == isCameraStreamStarted
          ? _value.isCameraStreamStarted
          : isCameraStreamStarted // ignore: cast_nullable_to_non_nullable
              as bool,
      rotateAngle: null == rotateAngle
          ? _value.rotateAngle
          : rotateAngle // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Control implements _Control {
  _$_Control(
      {this.frameInterval = 16,
      this.makeSequenceTime = 3,
      this.isCameraRotate = false,
      this.isCameraStreamStarted = false,
      this.rotateAngle = 0});

  factory _$_Control.fromJson(Map<String, dynamic> json) =>
      _$$_ControlFromJson(json);

  @override
  @JsonKey()
  final int frameInterval;
  @override
  @JsonKey()
  final int makeSequenceTime;
  @override
  @JsonKey()
  final bool isCameraRotate;
  @override
  @JsonKey()
  final bool isCameraStreamStarted;
  @override
  @JsonKey()
  final int rotateAngle;

  @override
  String toString() {
    return 'Control(frameInterval: $frameInterval, makeSequenceTime: $makeSequenceTime, isCameraRotate: $isCameraRotate, isCameraStreamStarted: $isCameraStreamStarted, rotateAngle: $rotateAngle)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Control &&
            (identical(other.frameInterval, frameInterval) ||
                other.frameInterval == frameInterval) &&
            (identical(other.makeSequenceTime, makeSequenceTime) ||
                other.makeSequenceTime == makeSequenceTime) &&
            (identical(other.isCameraRotate, isCameraRotate) ||
                other.isCameraRotate == isCameraRotate) &&
            (identical(other.isCameraStreamStarted, isCameraStreamStarted) ||
                other.isCameraStreamStarted == isCameraStreamStarted) &&
            (identical(other.rotateAngle, rotateAngle) ||
                other.rotateAngle == rotateAngle));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, frameInterval, makeSequenceTime,
      isCameraRotate, isCameraStreamStarted, rotateAngle);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ControlCopyWith<_$_Control> get copyWith =>
      __$$_ControlCopyWithImpl<_$_Control>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ControlToJson(
      this,
    );
  }
}

abstract class _Control implements Control {
  factory _Control(
      {final int frameInterval,
      final int makeSequenceTime,
      final bool isCameraRotate,
      final bool isCameraStreamStarted,
      final int rotateAngle}) = _$_Control;

  factory _Control.fromJson(Map<String, dynamic> json) = _$_Control.fromJson;

  @override
  int get frameInterval;
  @override
  int get makeSequenceTime;
  @override
  bool get isCameraRotate;
  @override
  bool get isCameraStreamStarted;
  @override
  int get rotateAngle;
  @override
  @JsonKey(ignore: true)
  _$$_ControlCopyWith<_$_Control> get copyWith =>
      throw _privateConstructorUsedError;
}
