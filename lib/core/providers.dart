import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/data/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
