import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart';

enum Config {
  socketDest('source destination', 'http://10.0.2.2:5000');

  Config({this.key, this.value});
  final String key;
  final String value;
}

@immutable
class ClientDesc {
  Client({required this.socketOpt});

  Socket? socket;
  final Map<String, dynamic> socketOpt = OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build();

  Client.buildSocket() {
    socket = 
  }

  bool get isInitialize => socket == null;
  
}

@immutable
class ClientDescription {
  Client({required this.socket, required this.socketOpt});

  final Socket socket;
  final Map<String, dynamic> socketOpt = OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build();

  ClientDescription copyWith({
    Socket? socket,
    Map<String, dynamic>? socketOpt
  }) => ClientDescription(socket: socket ?? this.socket, socketOpt: socketOpt ?? this.socketOpt);
}

class Client extends StateNotifier<ClientDescription> {
  Client() : super(Client());

  static final provider = StateNotifierProvider<Client, ClientDescription>((ref) => Client());

  void setSocket(Socket socket) {
    state = state.copyWith(socket: socket);
  }

  void setOption(Map<String, dynamic> opt) {
    state = state.copyWith(socketOpt: opt);
  }
}

final clientProvider = Provider<Client>(
  (ref) => Client(
    socket: io(
      'http://10.0.2.2:5000',
      OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
    ),
  ),
);
