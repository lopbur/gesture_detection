import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../util/common_util.dart';

<<<<<<< HEAD
=======
// import 'package:freezed_annotation/freezed_annotation.dart';
// part '../generated/provider/client.provider.freezed.dart';
// part '../generated/provider/client.provider.g.dart';

// @JsonSerializable()
// class SocketConverter implements JsonConverter<Socket?, Map<String, dynamic>?> {
//   const SocketConverter();

//   @override
//   Socket? fromJson(Map<String, dynamic>? json) {
//     if (json == null) {
//       return null;
//     }
//     final url = json['url'] as String?;
//     final transport = json['transport'] as String?;
//     if (url == null || transport == null) {
//       return null;
//     }
//     final options = OptionBuilder().setTransports([transport]).build();
//     return io(url, options);
//   }

//   @override
//   Map<String, dynamic>? toJson(Socket? socket) {
//     if (socket == null) {
//       return null;
//     }
//     return {
//       'url': socket.io.uri.toString(),
//       'path': socket.io.options['transports'],
//     };
//   }
// }

// @freezed
// class Client with _$Client {
//   @JsonSerializable(explicitToJson: true)
//   factory Client({
//     @JsonKey(fromJson: SocketConverter().fromJson, toJson: SocketConverter().toJson)
//         Socket? socket,
//     Map<String, dynamic>? socketOptions,
//     String? sourceDestination,
//     bool? isInitialized,
//     bool? isSocketUsed,
//   }) = _Client;

//   factory Client.fromJson(Map<String, dynamic> json) => _$ControlFromJson(json);
// }

>>>>>>> b7a943a58105d8d77f1bcca74eedecf0f0879b02
enum MessageType {
  requestStream('req_stream'),
  responseLandmark('res_landmark'),
  responseGesture('res_gesture');

  const MessageType(this.value);
  final String value;
}

final clientProvider =
    StateNotifierProvider<ClientProvider, Client>((ref) => ClientProvider());

@immutable
class Client {
  const Client({
    this.socket,
    this.socketOptions,
    this.sourceDestination,
    this.isInitialized = false,
    this.isSocketUsed = false,
  });

  final Socket? socket;
  final Map<String, dynamic>? socketOptions;
  final String? sourceDestination;
  final bool? isInitialized;
  final bool? isSocketUsed;

  Client copyWith({
    Socket? socket,
    Map<String, dynamic>? socketOptions,
    String? sourceDestination,
    bool? isInitialized,
    bool? isSocketUsed,
  }) =>
      Client(
        socket: socket ?? this.socket,
        socketOptions: socketOptions ?? this.socketOptions,
        sourceDestination: sourceDestination ?? this.sourceDestination,
        isInitialized: isInitialized ?? this.isInitialized,
        isSocketUsed: isSocketUsed ?? this.isSocketUsed,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is Client &&
        other.socket == socket &&
        mapEquals(other.socketOptions, socketOptions) &&
        other.sourceDestination == sourceDestination &&
        other.isInitialized == isInitialized &&
        other.isSocketUsed == isSocketUsed;
  }

  @override
  int get hashCode => Object.hash(
      socket, socketOptions, sourceDestination, isInitialized, isSocketUsed);

  @override
  String toString() {
    return '$runtimeType(socket: $socket, socketOptions: $socketOptions, '
        'sourceDestination: $sourceDestination, isInitialized: $isInitialized)';
  }
}

class ClientProvider extends StateNotifier<Client> {
  ClientProvider() : super(const Client());

  void connect() {
    final options = state.socketOptions ??
        OptionBuilder().setTransports(['websocket']).build();
    state = state.copyWith(
        socket: io(state.sourceDestination ?? 'http://10.0.2.2:5000', options));
    state.socket!.onConnect((_) => _setIsInitialized(true));
    state.socket!.onDisconnect((_) {
      _setIsInitialized(false);
      _reconnect();
    });
  }

  void disconnect() {
    if (state.socket?.connected ?? false) {
      state.socket!.dispose();
    }
    state = state.copyWith(socket: null);
  }

  void send(MessageType type, dynamic data) {
    final encoded = json.encode(data);
    if (state.socket?.connected ?? false) {
      state.socket!.emit(type.value, encoded);
    }
  }

  void setupMessage(String message, Function(dynamic) handler) {
    if (state.socket?.connected ?? false) {
      state.socket!.on(message, handler);
    }
  }

  void setOptions(Map<String, dynamic> newOptions) {
    state = state.copyWith(socketOptions: newOptions);
  }

  void setSourceDestination(String newSourceDestination) {
    state = state.copyWith(sourceDestination: newSourceDestination);
  }

  void _setIsInitialized(bool isInitialized) {
    state = state.copyWith(isInitialized: isInitialized);
  }

  void _reconnect() {
    Timer(const Duration(seconds: 5), () {
      if (!state.isInitialized! && !state.isSocketUsed!) {
        connect();
      }
    });
  }

  void reconnect() {
    disconnect();
    _reconnect();
  }
}
