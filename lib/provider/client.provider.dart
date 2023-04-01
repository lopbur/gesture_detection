import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:typed_data';

import '../util/common_util.dart';

part '../generated/provider/client.provider.freezed.dart';

enum MessageType {
  handStream('hand_stream'),
  registerGesture('register_gesture'),
  requestLandmark('request_landmark'),
  requestGesture('request_gesture');

  const MessageType(this.value);
  final String value;
}

final clientProvider =
    StateNotifierProvider<ClientProvider, Client>((ref) => ClientProvider());

@freezed
class Client with _$Client {
  factory Client({
    required io.Socket? socket,
    @Default('http://10.0.2.2:5000') String destination,
    @Default(false) bool isInitialized,
    @Default(false) bool isSocketUsed,
  }) = _Client;
}

class ClientProvider extends StateNotifier<Client> {
  ClientProvider()
      : super(
          Client(
            socket: io.io(
              'http://10.0.2.2:5000',
              io.OptionBuilder().setTransports(['websocket']).build(),
            ),
          ),
        );

  void connect() {
    if (state.socket?.connected ?? false) return;
    state = state.copyWith(
      socket: io.io(state.destination,
          io.OptionBuilder().setTransports(['websocket']).build()),
    );
  }

  void disconnect() {
    if (state.socket?.connected ?? false) {
      state.socket!.dispose();
    }

    state = state.copyWith(socket: null);
  }

  void setupMessage(String message, Function(dynamic) handler) {
    if (state.socket?.connected ?? false) {
      state.socket!.on(message, handler);
    }
  }

  void setOptions(Map<String, dynamic> newOptions) {
    state = state.copyWith(socket: io.io(''));
  }

  void setSourceDestination(String newSourceDestination) {
    state = state.copyWith(destination: newSourceDestination);
  }

  void setIsInitialized(bool isInitialized) {
    state = state.copyWith(isInitialized: isInitialized);
  }

  void send(MessageType type, dynamic data) {
    final encoded = json.encode(data);
    if (state.socket?.connected ?? false) {
      state.socket!.emit(type.value, encoded);
    }
  }

  /// Send seperate byte as chunk to server.
  ///
  /// [data] is receives [Uint8List] bytes value
  /// pass [chunkSize] value to set seperated chunk size.
  /// if pass null, set default chunkSize such as 100KB
  void sendByteChunk(
    MessageType type,
    Uint8List data,
    int chunkSize, [
    Map<String, dynamic>? additionalData,
  ]) async {
    if (additionalData != null) {
      send(type, additionalData);
    }

    int offset = 0;

    while (offset < data.length) {
      final int remaining = data.length - offset;
      final int chunkLength = remaining > chunkSize ? chunkSize : remaining;
      final Uint8List chunk = Uint8List.view(
        data.buffer,
        offset,
        chunkLength,
      );
      dev.log('Send data where range: $offset ~ ${offset + chunkLength}');
      offset += chunkLength;

      final bool isLastChunk = (offset == data.length);

      // send the chunk to the server
      send(type, {'data': chunk, 'isLastChunk': isLastChunk});
    }
  }
}
