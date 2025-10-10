import 'package:flutter/material.dart';
import 'package:napphy_services/models/user_model.dart';
import 'package:napphy_services/config/routes.dart';
import 'package:napphy_services/services/auth_service.dart';

Future<void> navigateByRole(BuildContext context, AuthService auth) async {
  // Espera breve si el modelo aún no cargó
  if (auth.currentUserModel == null) {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  if (!context.mounted) return;

  final role = auth.currentUserModel?.role ?? UserRole.parent;
  debugPrint('navigateByRole: role=$role');

  switch (role) {
    case UserRole.nanny:
      Navigator.pushReplacementNamed(context, Routes.nannyHome);
      break;
    case UserRole.admin:
      Navigator.pushReplacementNamed(context, Routes.adminDashboard);
      break;
    case UserRole.parent:
    default:
      Navigator.pushReplacementNamed(context, Routes.parentHome);
      break;
  }
}