import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:napphy_services/config/routes.dart';
import 'package:napphy_services/services/auth_service.dart';
import 'package:napphy_services/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final x = (v ?? '').trim();
    if (x.isEmpty) return 'Por favor ingresa tu correo';
    if (!x.contains('@') || !x.contains('.')) return 'Ingresa un correo válido';
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();

    final cred = await authService.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (cred == null) {
      // Mostrar error si falló el login
      final msg = authService.errorMessage ?? 'Error al iniciar sesión';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
      return;
    }

    // Si llegó aquí, el login fue exitoso.
    // AuthService ya intenta cargar el UserModel en signInWithEmail.
    // Damos un pequeño tiempo para que se propague y, si no llega, leemos role directo del doc.
    UserRole? role = authService.currentUserModel?.role;

    if (role == null) {
      try {
        final uid = cred.user!.uid;
        // Leer role directamente desde Firestore por si aún no está en memoria.
        final doc = await authService
            .currentUser // el service ya tiene el auth instance
            ?.reload(); // aseguramos datos frescos (no bloquea)

        // Volvemos a tomar el modelo por si ya cargó
        role = authService.currentUserModel?.role;

        // Si aún nada, hacemos una pequeña espera y reintentamos
        if (role == null) {
          await Future.delayed(const Duration(milliseconds: 150));
          role = authService.currentUserModel?.role;
        }

        // En el peor caso (sigue null), asumimos parent para no bloquear
        role ??= UserRole.parent;
      } catch (_) {
        role = UserRole.parent;
      }
    }

    // Navegar según rol
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  Icon(
                    Icons.child_care,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Napphy Services',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Inicia sesión para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Correo
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'tu@email.com',
                    ),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // Contraseña
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Recuperar contraseña'),
                            content: const Text('Funcionalidad próximamente disponible.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón de iniciar sesión con estado de carga
                  Consumer<AuthService>(
                    builder: (context, authService, _) {
                      return SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: authService.isLoading ? null : _handleLogin,
                          child: authService.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Iniciar sesión',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('¿No tienes una cuenta?', style: TextStyle(color: Colors.grey[600])),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.roleSelection);
                        },
                        child: const Text('Regístrate'),
                      ),
                    ],
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