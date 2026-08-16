import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/stage_service.dart';

final stagesProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = ref.read(stageServiceProvider);
  return service.getStages();
});
