import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/rider_profile_provider.dart';

class RiderProfileScreen extends ConsumerWidget {
  const RiderProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(riderProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль райдера')),
      body: profileAsync.when(
        data: (profile) {
          final user = profile['user'] as Map<String, dynamic>? ?? {};
          final bikeModel = profile['bikeModel'] ?? '—';
          final allergies = (profile['allergies'] as List<dynamic>?)?.join(', ') ?? 'нет';
          final status = profile['status'] ?? '—';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.person, size: 96, color: AppColors.neon),
                const SizedBox(height: 16),
                Text(user['name'] ?? 'Имя', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(user['email'] ?? 'Email', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 24),
                _buildInfoRow('Велосипед', bikeModel),
                _buildInfoRow('Аллергии', allergies),
                _buildInfoRow('Статус', status),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.cream)),
        ],
      ),
    );
  }
}
