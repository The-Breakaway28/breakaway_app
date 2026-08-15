// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/riders_status_provider.dart';

class ChefDashboardScreen extends ConsumerWidget {
  const ChefDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final ridersAsync = ref.watch(ridersStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chef Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: ridersAsync.when(
          data: (riders) {
            if (riders.isEmpty) {
              return const Text('Нет данных о райдерах');
            }
            return ListView.builder(
              itemCount: riders.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final rider = riders[index];
                final name = rider['name'] ?? '—';
                final allergies = (rider['allergies'] as List<dynamic>?)?.join(', ') ?? 'нет';
                final status = rider['status'] ?? 'ok';

                return Card(
                  color: AppColors.emeraldSurface,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(name, style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text('Аллергии: $allergies'),
                    trailing: Icon(
                      status == 'critical' ? Icons.error : status == 'warning' ? Icons.warning : Icons.check_circle,
                      color: status == 'critical' ? AppColors.error : status == 'warning' ? Colors.orange : AppColors.neon,
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Ошибка загрузки: $error'),
        ),
      ),
    );
  }
}
