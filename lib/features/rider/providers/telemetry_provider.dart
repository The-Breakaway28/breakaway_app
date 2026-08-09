import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../data/telemetry_service.dart';

final telemetryServiceProvider = Provider<TelemetryService>((ref) => TelemetryService());

final riderTelemetryProvider = FutureProvider.family<List<dynamic>, String>(
  (ref, riderId) async {
    final authService = ref.read(authServiceProvider);
    final token = await authService.getToken();
    if (token == null) throw Exception('Не авторизован');

    final telemetryService = ref.read(telemetryServiceProvider);
    return telemetryService.getRiderTelemetry(riderId, token);
  },
);
