// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../provider/gesture_train.provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

TrainSet _$TrainSetFromJson(Map<String, dynamic> json) {
  return _TrainSet.fromJson(json);
}

/// @nodoc
mixin _$TrainSet {
  @Uint8ListConverter()
  List<Uint8List> get planes => throw _privateConstructorUsedError;
  String get format => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrainSetCopyWith<TrainSet> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainSetCopyWith<$Res> {
  factory $TrainSetCopyWith(TrainSet value, $Res Function(TrainSet) then) =
      _$TrainSetCopyWithImpl<$Res, TrainSet>;
  @useResult
  $Res call(
      {@Uint8ListConverter() List<Uint8List> planes,
      String format,
      String label});
}

/// @nodoc
class _$TrainSetCopyWithImpl<$Res, $Val extends TrainSet>
    implements $TrainSetCopyWith<$Res> {
  _$TrainSetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? planes = null,
    Object? format = null,
    Object? label = null,
  }) {
    return _then(_value.copyWith(
      planes: null == planes
          ? _value.planes
          : planes // ignore: cast_nullable_to_non_nullable
              as List<Uint8List>,
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_TrainSetCopyWith<$Res> implements $TrainSetCopyWith<$Res> {
  factory _$$_TrainSetCopyWith(
          _$_TrainSet value, $Res Function(_$_TrainSet) then) =
      __$$_TrainSetCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@Uint8ListConverter() List<Uint8List> planes,
      String format,
      String label});
}

/// @nodoc
class __$$_TrainSetCopyWithImpl<$Res>
    extends _$TrainSetCopyWithImpl<$Res, _$_TrainSet>
    implements _$$_TrainSetCopyWith<$Res> {
  __$$_TrainSetCopyWithImpl(
      _$_TrainSet _value, $Res Function(_$_TrainSet) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? planes = null,
    Object? format = null,
    Object? label = null,
  }) {
    return _then(_$_TrainSet(
      planes: null == planes
          ? _value._planes
          : planes // ignore: cast_nullable_to_non_nullable
              as List<Uint8List>,
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_TrainSet with DiagnosticableTreeMixin implements _TrainSet {
  _$_TrainSet(
      {@Uint8ListConverter() final List<Uint8List> planes = const [],
      this.format = 'YUV420',
      this.label = 'My gesture'})
      : _planes = planes;

  factory _$_TrainSet.fromJson(Map<String, dynamic> json) =>
      _$$_TrainSetFromJson(json);

  final List<Uint8List> _planes;
  @override
  @JsonKey()
  @Uint8ListConverter()
  List<Uint8List> get planes {
    if (_planes is EqualUnmodifiableListView) return _planes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_planes);
  }

  @override
  @JsonKey()
  final String format;
  @override
  @JsonKey()
  final String label;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TrainSet(planes: $planes, format: $format, label: $label)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TrainSet'))
      ..add(DiagnosticsProperty('planes', planes))
      ..add(DiagnosticsProperty('format', format))
      ..add(DiagnosticsProperty('label', label));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_TrainSet &&
            const DeepCollectionEquality().equals(other._planes, _planes) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_planes), format, label);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TrainSetCopyWith<_$_TrainSet> get copyWith =>
      __$$_TrainSetCopyWithImpl<_$_TrainSet>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_TrainSetToJson(
      this,
    );
  }
}

abstract class _TrainSet implements TrainSet {
  factory _TrainSet(
      {@Uint8ListConverter() final List<Uint8List> planes,
      final String format,
      final String label}) = _$_TrainSet;

  factory _TrainSet.fromJson(Map<String, dynamic> json) = _$_TrainSet.fromJson;

  @override
  @Uint8ListConverter()
  List<Uint8List> get planes;
  @override
  String get format;
  @override
  String get label;
  @override
  @JsonKey(ignore: true)
  _$$_TrainSetCopyWith<_$_TrainSet> get copyWith =>
      throw _privateConstructorUsedError;
}
