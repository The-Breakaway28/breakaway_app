import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/chef_service.dart';

final ridersStatusProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = ref.read(chefServiceProvider);
  return service.getRidersStatus();
});
