// ignore_for_file: avoid_print
import 'package:socket_io_client/socket_io_client.dart' as io;

class TelemetrySocketService {
  io.Socket? _socket;

  void connect() {
    if (_socket != null) return;

    _socket = io.io(
      'https://breakaway-api.duckdns.org',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.on('connect', (_) {
      print('Socket connected');
    });

    _socket!.on('disconnect', (_) {
      print('Socket disconnected');
    });
  }

  void listenToTelemetry(void Function(Map<String, dynamic>) onData) {
    _socket?.on('telemetry:update', (data) {
      final map = Map<String, dynamic>.from(data as Map);
      onData(map);
    });
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
