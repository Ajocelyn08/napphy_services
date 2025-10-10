import 'package:flutter/material.dart';
import 'package:napphy_services/models/user_model.dart';
import 'package:napphy_services/screens/common/splash_screen.dart';
import 'package:napphy_services/screens/auth/login_screen.dart';
import 'package:napphy_services/screens/auth/register_screen.dart';
import 'package:napphy_services/screens/auth/role_selection_screen.dart';
import 'package:napphy_services/screens/nanny/nanny_home_screen.dart';
import 'package:napphy_services/screens/nanny/nanny_profile_screen.dart';
import 'package:napphy_services/screens/parent/parent_home_screen.dart';
import 'package:napphy_services/screens/parent/search_nannies_screen.dart';
import 'package:napphy_services/screens/parent/nanny_detail_screen.dart';
import 'package:napphy_services/screens/admin/admin_dashboard_screen.dart';
import 'package:napphy_services/screens/chat/chat_list_screen.dart';
import 'package:napphy_services/screens/chat/chat_screen.dart';
import 'package:napphy_services/screens/common/notifications_screen.dart';
import 'package:napphy_services/screens/common/settings_screen.dart';

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String roleSelection = '/role-selection';

  // Nanny routes
  static const String nannyHome = '/nanny/home';
  static const String nannyProfile = '/nanny/profile';

  // Parent routes
  static const String parentHome = '/parent/home';
  static const String searchNannies = '/parent/search';
  static const String nannyDetail = '/parent/nanny-detail';

  // Admin routes
  static const String adminDashboard = '/admin/dashboard';

  // Common routes
  static const String chatList = '/chat/list';
  static const String chat = '/chat';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        // Lee el rol enviado desde RoleSelection
        final args = (settings.arguments as Map<String, dynamic>?) ?? {};
        final role = args['role'] as UserRole?;
        return MaterialPageRoute(
          builder: (_) => RegisterScreen(presetRole: role),
        );

      case roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());

      case nannyHome:
        return MaterialPageRoute(builder: (_) => const NannyHomeScreen());

      case nannyProfile:
        return MaterialPageRoute(builder: (_) => const NannyProfileScreen());

      case parentHome:
        return MaterialPageRoute(builder: (_) => const ParentHomeScreen());

      case searchNannies:
        return MaterialPageRoute(builder: (_) => const SearchNanniesScreen());

      case nannyDetail:
        final args = (settings.arguments as Map<String, dynamic>?) ?? {};
        final nannyId = args['nannyId'] as String?;
        if (nannyId == null) {
          return _errorRoute('Falta parámetro: nannyId');
        }
        return MaterialPageRoute(
          builder: (_) => NannyDetailScreen(nannyId: nannyId),
        );

      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

      case chatList:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());

      case chat:
        final args = (settings.arguments as Map<String, dynamic>?) ?? {};
        final receiverId = args['receiverId'] as String?;
        final receiverName = args['receiverName'] as String?;
        if (receiverId == null || receiverName == null) {
          return _errorRoute('Faltan parámetros: receiverId o receiverName');
        }
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            receiverId: receiverId,
            receiverName: receiverName,
          ),
        );

      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      default:
        return _errorRoute('Ruta no encontrada: ${settings.name}');
    }
  }

  static MaterialPageRoute _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(child: Text(message)),
      ),
    );
  }
}