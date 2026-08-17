import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
      // После успешной регистрации сразу входим и переходим на дашборд
      final role = await authService.getRole();
      if (!mounted) return;
      String route;
      switch (role) {
        case 'driver':
          route = '/driver-dashboard';
          break;
        case 'chef':
          route = '/chef-dashboard';
          break;
        case 'ceo':
          route = '/ceo-dashboard';
          break;
        default:
          route = '/rider-dashboard';
      }
      Navigator.pushReplacementNamed(context, route);
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text('THE BREAKAWAY', textAlign: TextAlign.center,
                    style: textTheme.displayLarge?.copyWith(fontSize: 24, letterSpacing: 3)),
                const SizedBox(height: 8),
                Text('Присоединяйтесь к отрыву', textAlign: TextAlign.center,
                    style: textTheme.bodyMedium),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'ИМЯ'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Введите имя'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'EMAIL'),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return 'Введите email';
                    if (!v.contains('@') || !v.contains('.')) return 'Некорректный email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(labelText: 'ПАРОЛЬ'),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Введите пароль'
                      : null,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(_errorMessage!,
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.error)),
                ],
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: AppColors.emeraldDeep),
                        )
                      : const Text('ЗАРЕГИСТРИРОВАТЬСЯ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
