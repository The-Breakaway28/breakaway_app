import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_service.dart';
import '../data/telemetry_socket_service.dart';

final liveTelemetryServiceProvider = Provider<TelemetrySocketService>((ref) {
  final token = AuthService.currentToken;
  final service = TelemetrySocketService(token ?? '');
  service.connect();
  return service;
});

final liveTelemetryProvider = StateNotifierProvider<LiveTelemetryNotifier, Map<String, dynamic>?>((ref) {
  final service = ref.watch(liveTelemetryServiceProvider);
  return LiveTelemetryNotifier(service);
});

class LiveTelemetryNotifier extends StateNotifier<Map<String, dynamic>?> {
  LiveTelemetryNotifier(TelemetrySocketService service) : super(null) {
    service.listenToTelemetry((data) {
      state = data;
    });
  }
}
