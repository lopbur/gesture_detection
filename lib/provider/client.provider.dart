import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart';

enum MessageType {
  requestStream('req_stream'),
  responseLandmark('res_landmark'),
  responseGesture('res_gesture');

  const MessageType(this.value);
  final String value;
}

bool mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
  if (identical(a, b)) {
    return true;
  }
  if (a == null || b == null || a.length != b.length) {
    return false;
  }
  for (var key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) {
      return false;
    }
  }
  return true;
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
    state.socket!.onDisconnect((_) => _setIsInitialized(false));
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
}
