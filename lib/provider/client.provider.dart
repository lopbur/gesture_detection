import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart';

class Client {
  Client({required this.socket});

  Socket socket;
}

final clientProvider = Provider<Client>(
  (ref) => Client(
    socket: io(
      'http://10.0.2.2:5000',
      OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
    ),
  ),
);
