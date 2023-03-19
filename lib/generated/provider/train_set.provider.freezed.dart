// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../provider/train_set.provider.dart';

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
  List<Uint8List> get train => throw _privateConstructorUsedError;

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
  $Res call({@Uint8ListConverter() List<Uint8List> train});
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
    Object? train = null,
  }) {
    return _then(_value.copyWith(
      train: null == train
          ? _value.train
          : train // ignore: cast_nullable_to_non_nullable
              as List<Uint8List>,
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
  $Res call({@Uint8ListConverter() List<Uint8List> train});
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
    Object? train = null,
  }) {
    return _then(_$_TrainSet(
      train: null == train
          ? _value._train
          : train // ignore: cast_nullable_to_non_nullable
              as List<Uint8List>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_TrainSet with DiagnosticableTreeMixin implements _TrainSet {
  _$_TrainSet({@Uint8ListConverter() final List<Uint8List> train = const []})
      : _train = train;

  factory _$_TrainSet.fromJson(Map<String, dynamic> json) =>
      _$$_TrainSetFromJson(json);

  final List<Uint8List> _train;
  @override
  @JsonKey()
  @Uint8ListConverter()
  List<Uint8List> get train {
    if (_train is EqualUnmodifiableListView) return _train;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_train);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TrainSet(train: $train)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TrainSet'))
      ..add(DiagnosticsProperty('train', train));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_TrainSet &&
            const DeepCollectionEquality().equals(other._train, _train));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_train));

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
  factory _TrainSet({@Uint8ListConverter() final List<Uint8List> train}) =
      _$_TrainSet;

  factory _TrainSet.fromJson(Map<String, dynamic> json) = _$_TrainSet.fromJson;

  @override
  @Uint8ListConverter()
  List<Uint8List> get train;
  @override
  @JsonKey(ignore: true)
  _$$_TrainSetCopyWith<_$_TrainSet> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TrainSetPreview {
  List<CameraImage> get trainPreview => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TrainSetPreviewCopyWith<TrainSetPreview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainSetPreviewCopyWith<$Res> {
  factory $TrainSetPreviewCopyWith(
          TrainSetPreview value, $Res Function(TrainSetPreview) then) =
      _$TrainSetPreviewCopyWithImpl<$Res, TrainSetPreview>;
  @useResult
  $Res call({List<CameraImage> trainPreview, String label});
}

/// @nodoc
class _$TrainSetPreviewCopyWithImpl<$Res, $Val extends TrainSetPreview>
    implements $TrainSetPreviewCopyWith<$Res> {
  _$TrainSetPreviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trainPreview = null,
    Object? label = null,
  }) {
    return _then(_value.copyWith(
      trainPreview: null == trainPreview
          ? _value.trainPreview
          : trainPreview // ignore: cast_nullable_to_non_nullable
              as List<CameraImage>,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_TrainSetPreviewCopyWith<$Res>
    implements $TrainSetPreviewCopyWith<$Res> {
  factory _$$_TrainSetPreviewCopyWith(
          _$_TrainSetPreview value, $Res Function(_$_TrainSetPreview) then) =
      __$$_TrainSetPreviewCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<CameraImage> trainPreview, String label});
}

/// @nodoc
class __$$_TrainSetPreviewCopyWithImpl<$Res>
    extends _$TrainSetPreviewCopyWithImpl<$Res, _$_TrainSetPreview>
    implements _$$_TrainSetPreviewCopyWith<$Res> {
  __$$_TrainSetPreviewCopyWithImpl(
      _$_TrainSetPreview _value, $Res Function(_$_TrainSetPreview) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trainPreview = null,
    Object? label = null,
  }) {
    return _then(_$_TrainSetPreview(
      trainPreview: null == trainPreview
          ? _value._trainPreview
          : trainPreview // ignore: cast_nullable_to_non_nullable
              as List<CameraImage>,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_TrainSetPreview
    with DiagnosticableTreeMixin
    implements _TrainSetPreview {
  _$_TrainSetPreview(
      {final List<CameraImage> trainPreview = const [],
      this.label = 'New Gesture'})
      : _trainPreview = trainPreview;

  final List<CameraImage> _trainPreview;
  @override
  @JsonKey()
  List<CameraImage> get trainPreview {
    if (_trainPreview is EqualUnmodifiableListView) return _trainPreview;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trainPreview);
  }

  @override
  @JsonKey()
  final String label;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TrainSetPreview(trainPreview: $trainPreview, label: $label)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TrainSetPreview'))
      ..add(DiagnosticsProperty('trainPreview', trainPreview))
      ..add(DiagnosticsProperty('label', label));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_TrainSetPreview &&
            const DeepCollectionEquality()
                .equals(other._trainPreview, _trainPreview) &&
            (identical(other.label, label) || other.label == label));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_trainPreview), label);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TrainSetPreviewCopyWith<_$_TrainSetPreview> get copyWith =>
      __$$_TrainSetPreviewCopyWithImpl<_$_TrainSetPreview>(this, _$identity);
}

abstract class _TrainSetPreview implements TrainSetPreview {
  factory _TrainSetPreview(
      {final List<CameraImage> trainPreview,
      final String label}) = _$_TrainSetPreview;

  @override
  List<CameraImage> get trainPreview;
  @override
  String get label;
  @override
  @JsonKey(ignore: true)
  _$$_TrainSetPreviewCopyWith<_$_TrainSetPreview> get copyWith =>
      throw _privateConstructorUsedError;
}
