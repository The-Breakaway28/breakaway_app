import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/telemetry_socket_service.dart';

final liveTelemetryServiceProvider = Provider<TelemetrySocketService>((ref) {
  final service = TelemetrySocketService();
  service.connect();
  return service;
});

final liveTelemetryProvider = StateNotifierProvider<LiveTelemetryNotifier, Map<String, dynamic>?>((ref) {
  final service = ref.watch(liveTelemetryServiceProvider);
  final notifier = LiveTelemetryNotifier(service);
  return notifier;
});

class LiveTelemetryNotifier extends StateNotifier<Map<String, dynamic>?> {
  LiveTelemetryNotifier(TelemetrySocketService service) : super(null) {
    service.listenToTelemetry((data) {
      state = data;
    });
  }
}
