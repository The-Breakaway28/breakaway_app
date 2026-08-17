// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
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
      await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  Text('🚴‍♂️', textAlign: TextAlign.center, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 28),
                  Text(
                    'THE BREAKAWAY',
                    textAlign: TextAlign.center,
                    style: textTheme.displayLarge?.copyWith(fontSize: 26, letterSpacing: 3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Главный отрыв в жизни',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 48),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          style: textTheme.bodyLarge,
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
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          style: textTheme.bodyLarge,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: 'ПАРОЛЬ',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                              tooltip: _obscurePassword ? 'Показать пароль' : 'Скрыть пароль',
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (value) => (value ?? '').isEmpty ? 'Введите пароль' : null,
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
                          ),
                        ],
                        const SizedBox(height: 28),
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor: AlwaysStoppedAnimation(AppColors.emeraldDeep),
                                  ),
                                )
                              : const Text('ВОЙТИ'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.pushNamed(context, '/register'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.neon,
                            side: const BorderSide(color: AppColors.neon),
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          child: const Text('СОЗДАТЬ АККАУНТ'),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: _isSubmitting ? null : () {},
                            child: const Text('Забыли пароль?'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 3),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      'BREAKAWAY OS',
                      textAlign: TextAlign.center,
                      style: textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
