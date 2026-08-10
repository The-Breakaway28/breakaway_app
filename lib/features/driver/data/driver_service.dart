import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final driverServiceProvider = Provider<DriverService>((ref) {
  final authService = ref.read(authServiceProvider);
  final apiClient = ApiClient(authService);
  return DriverService(apiClient);
});

class DriverService {
  final ApiClient _apiClient;
  DriverService(this._apiClient);
  static const String _baseUrl = 'http://178.104.120.91:3000';

  Future<Map<String, dynamic>> getVehicle(String vehicleId) async {
    final response = await _apiClient.get('$_baseUrl/vehicles/$vehicleId');
    if (response.statusCode != 200) {
      throw Exception('Failed to load vehicle');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
