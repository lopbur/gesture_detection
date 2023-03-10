import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart';

enum Config {
  socketDest('source destination', 'http://10.0.2.2:5000');

  const Config(this.key, this.value);
  final String key;
  final String value;
}

@immutable
class ClientModel {
  const ClientModel({
    required this.socket,
    required this.socketOptions,
    required this.isInitialize,
  });

  final Socket socket;
  final Map<String, dynamic> socketOptions;
  final bool isInitialize;

  ClientModel copyWith({
    Socket? socket,
    Map<String, dynamic>? socketOptions,
    bool? isInitialize,
  }) =>
      ClientModel(
        socket: socket ?? this.socket,
        socketOptions: socketOptions ?? this.socketOptions,
        isInitialize: isInitialize ?? this.isInitialize,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ClientModel &&
        other.socket == socket &&
        other.socketOptions == socketOptions &&
        other.isInitialize == isInitialize;
  }

  @override
  int get hashCode =>
      socket.hashCode ^ socketOptions.hashCode ^ isInitialize.hashCode;
}

// @immutable
// class ClientDescription {
//   Client({required this.socket, required this.socketOpt});

//   final Socket socket;
//   final Map<String, dynamic> socketOpt = OptionBuilder()
//       .setTransports(['websocket'])
//       .disableAutoConnect()
//       .build();

//   ClientDescription copyWith({
//     Socket? socket,
//     Map<String, dynamic>? socketOpt
//   }) => ClientDescription(socket: socket ?? this.socket, socketOpt: socketOpt ?? this.socketOpt);
// }

class Client extends StateNotifier<ClientModel?> {
  Client() : super(null);

  // static final provider =
  //     StateNotifierProvider<Client, ClientModel?>((ref) => Client());

  // void setSocket(Socket socket) {
  //   state = state.copyWith(socket: socket);
  // }

  // void setOption(Map<String, dynamic> opt) {
  //   state = state.copyWith(socketOpt: opt);
  // }
}

final clientProvider = Provider<Client>(
  (ref) => Client(),
);
