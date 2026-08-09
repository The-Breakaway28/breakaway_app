import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';

class CEODashboardScreen extends ConsumerWidget {
  const CEODashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CEO Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insights,
              size: 80,
              color: AppColors.neon,
            ),
            const SizedBox(height: 24),
            Text(
              'Добро пожаловать, CEO!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            const Text('Здесь будут общая карта, алерты и утренний брифинг.'),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () async {
                await authService.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Выйти'),
            ),
          ],
        ),
      ),
    );
  }
}
