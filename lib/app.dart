import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/rider/presentation/rider_dashboard_screen.dart';
import 'features/driver/presentation/driver_dashboard_screen.dart';
import 'features/chef/presentation/chef_dashboard_screen.dart';
import 'features/ceo/presentation/ceo_dashboard_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Breakaway',
      theme: AppTheme.dark,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/rider-dashboard': (context) => const RiderDashboardScreen(),
        '/driver-dashboard': (context) => const DriverDashboardScreen(),
        '/chef-dashboard': (context) => const ChefDashboardScreen(),
        '/ceo-dashboard': (context) => const CEODashboardScreen(),
      },
    );
  }
}
