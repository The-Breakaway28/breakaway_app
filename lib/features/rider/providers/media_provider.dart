import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../data/media_service.dart';

final mediaServiceProvider = Provider<MediaService>((ref) => MediaService());

final mediaClipsProvider = FutureProvider<List<dynamic>>((ref) async {
  final authService = ref.read(authServiceProvider);
  final token = await authService.getToken();
  if (token == null) throw Exception('Не авторизован');
  final service = ref.read(mediaServiceProvider);
  return service.getMediaClips(token);
});
