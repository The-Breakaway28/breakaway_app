import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/driver_service.dart';

final vehicleProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(driverServiceProvider);
  return service.getVehicle('df07f6d8-5b81-4c12-88b6-0c0f62a229a2');
});
