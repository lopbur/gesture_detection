// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../provider/client.provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Client {
  io.Socket? get socket => throw _privateConstructorUsedError;
  String get destination => throw _privateConstructorUsedError;
  bool get isInitialized => throw _privateConstructorUsedError;
  bool get isSocketUsed => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ClientCopyWith<Client> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClientCopyWith<$Res> {
  factory $ClientCopyWith(Client value, $Res Function(Client) then) =
      _$ClientCopyWithImpl<$Res, Client>;
  @useResult
  $Res call(
      {io.Socket? socket,
      String destination,
      bool isInitialized,
      bool isSocketUsed});
}

/// @nodoc
class _$ClientCopyWithImpl<$Res, $Val extends Client>
    implements $ClientCopyWith<$Res> {
  _$ClientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? socket = freezed,
    Object? destination = null,
    Object? isInitialized = null,
    Object? isSocketUsed = null,
  }) {
    return _then(_value.copyWith(
      socket: freezed == socket
          ? _value.socket
          : socket // ignore: cast_nullable_to_non_nullable
              as io.Socket?,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      isSocketUsed: null == isSocketUsed
          ? _value.isSocketUsed
          : isSocketUsed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ClientCopyWith<$Res> implements $ClientCopyWith<$Res> {
  factory _$$_ClientCopyWith(_$_Client value, $Res Function(_$_Client) then) =
      __$$_ClientCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {io.Socket? socket,
      String destination,
      bool isInitialized,
      bool isSocketUsed});
}

/// @nodoc
class __$$_ClientCopyWithImpl<$Res>
    extends _$ClientCopyWithImpl<$Res, _$_Client>
    implements _$$_ClientCopyWith<$Res> {
  __$$_ClientCopyWithImpl(_$_Client _value, $Res Function(_$_Client) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? socket = freezed,
    Object? destination = null,
    Object? isInitialized = null,
    Object? isSocketUsed = null,
  }) {
    return _then(_$_Client(
      socket: freezed == socket
          ? _value.socket
          : socket // ignore: cast_nullable_to_non_nullable
              as io.Socket?,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as String,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      isSocketUsed: null == isSocketUsed
          ? _value.isSocketUsed
          : isSocketUsed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$_Client implements _Client {
  _$_Client(
      {this.socket,
      this.destination = 'http://10.0.2.2:5000',
      this.isInitialized = false,
      this.isSocketUsed = false});

  @override
  final io.Socket? socket;
  @override
  @JsonKey()
  final String destination;
  @override
  @JsonKey()
  final bool isInitialized;
  @override
  @JsonKey()
  final bool isSocketUsed;

  @override
  String toString() {
    return 'Client(socket: $socket, destination: $destination, isInitialized: $isInitialized, isSocketUsed: $isSocketUsed)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Client &&
            (identical(other.socket, socket) || other.socket == socket) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized) &&
            (identical(other.isSocketUsed, isSocketUsed) ||
                other.isSocketUsed == isSocketUsed));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, socket, destination, isInitialized, isSocketUsed);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_ClientCopyWith<_$_Client> get copyWith =>
      __$$_ClientCopyWithImpl<_$_Client>(this, _$identity);
}

abstract class _Client implements Client {
  factory _Client(
      {final io.Socket? socket,
      final String destination,
      final bool isInitialized,
      final bool isSocketUsed}) = _$_Client;

  @override
  io.Socket? get socket;
  @override
  String get destination;
  @override
  bool get isInitialized;
  @override
  bool get isSocketUsed;
  @override
  @JsonKey(ignore: true)
  _$$_ClientCopyWith<_$_Client> get copyWith =>
      throw _privateConstructorUsedError;
}
