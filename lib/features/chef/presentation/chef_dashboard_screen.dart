import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/riders_status_provider.dart';
import '../data/chef_service.dart';

class ChefDashboardScreen extends ConsumerStatefulWidget {
  const ChefDashboardScreen({super.key});

  @override
  ConsumerState<ChefDashboardScreen> createState() => _ChefDashboardScreenState();
}

class _ChefDashboardScreenState extends ConsumerState<ChefDashboardScreen> {
  Map<String, dynamic>? _mealPlan;

  Future<void> _loadMealPlan() async {
    final authService = ref.read(authServiceProvider);
    final token = await authService.getToken();
    if (token == null) return;
    final service = ref.read(chefServiceProvider);
    final result = await service.generateMealPlan();
    setState(() => _mealPlan = result);
  }

  @override
  void initState() {
    super.initState();
    _loadMealPlan();
  }

  String _getMealIcon(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return '🍳';
      case 'lunch':
        return '🍝';
      case 'dinner':
        return '🍚';
      default:
        return '🍽️';
    }
  }

  @override
  Widget build(BuildContext context) {
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
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: ridersAsync.when(
        data: (riders) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Райдеры', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ...riders.map((rider) {
                final name = rider['name'] ?? '—';
                final allergies = (rider['allergies'] as List<dynamic>?)?.join(', ') ?? 'нет';
                final status = rider['status'] ?? 'ok';
                return Card(
                  color: AppColors.emeraldSurface,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text('Аллергии: $allergies'),
                    trailing: Icon(
                      status == 'critical' ? Icons.error : status == 'warning' ? Icons.warning : Icons.check_circle,
                      color: status == 'critical' ? AppColors.error : status == 'warning' ? Colors.orange : AppColors.neon,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              Text('Меню на день', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (_mealPlan == null)
                const Center(child: CircularProgressIndicator())
              else ...[
                ...((_mealPlan!['meals'] as List<dynamic>?) ?? []).map((meal) {
                  final mealType = meal['meal'] as String? ?? '';
                  final name = meal['name'] ?? '—';
                  final recipe = meal['recipe'] ?? '';
                  final ingredients = (meal['ingredients'] as List<dynamic>?)?.join(', ') ?? '';
                  return Card(
                    color: AppColors.emeraldSurface,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(_getMealIcon(mealType), style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(name,
                                    style: Theme.of(context).textTheme.titleMedium),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Рецепт: $recipe',
                              style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          Text('Ингредиенты: $ingredients',
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                Text('Список покупок', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Card(
                  color: AppColors.emeraldSurface,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text((_mealPlan!['shoppingList'] as List<dynamic>?)?.join(', ') ?? ''),
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
      ),
    );
  }
}
