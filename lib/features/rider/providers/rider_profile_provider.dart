import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../data/rider_service.dart';

final riderServiceProvider = Provider<RiderService>((ref) => RiderService());

final riderProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final authService = ref.read(authServiceProvider);
  final token = await authService.getToken();
  if (token == null) throw Exception('Не авторизован');
  final service = ref.read(riderServiceProvider);
  return service.getMyProfile(token);
});
