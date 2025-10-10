import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:napphy_services/config/routes.dart';
import 'package:napphy_services/services/auth_service.dart';
import 'package:napphy_services/models/user_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}



class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final auth = context.read<AuthService>();
      _waitAndNavigate(auth, attempts: 20);
    });
  }

  Future<void> _waitAndNavigate(AuthService auth, {int attempts = 20}) async {
    for (int i = 0; i < attempts; i++) {
      if (!mounted) return;

      final user = auth.currentUser;
      final model = auth.currentUserModel;

      debugPrint('Splash attempt $i: user=${user?.uid}, model role=${model?.role}');

      if (user == null) {
        _go(Routes.login);
        return;
      }

      if (model != null) {
        switch (model.role) {
          case UserRole.nanny:
            debugPrint('Splash: navegando a nannyHome');
            _go(Routes.nannyHome);
            return;
          case UserRole.parent:
            debugPrint('Splash: navegando a parentHome');
            _go(Routes.parentHome);
            return;
          case UserRole.admin:
            debugPrint('Splash: navegando a adminDashboard');
            _go(Routes.adminDashboard);
            return;
        }
      }

      await Future.delayed(const Duration(milliseconds: 150));
    }

    debugPrint('Splash: timeout, navegando a login');
    _go(Routes.login);
  }

  void _go(String route) {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_care, size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            const Text(
              'Napphy Services',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}