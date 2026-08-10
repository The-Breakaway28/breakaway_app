import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ceo_service.dart';

final allVehiclesProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = ref.read(ceoServiceProvider);
  return service.getAllVehicles();
});
