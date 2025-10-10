import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:napphy_services/config/routes.dart';
import 'package:napphy_services/services/auth_service.dart';
import 'package:napphy_services/models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  final UserRole? presetRole; // opcional, por si vienes desde role_selection

  const RegisterScreen({super.key, this.presetRole});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  UserRole? _role;

  @override
  void initState() {
    super.initState();
    _role = widget.presetRole ?? UserRole.parent; // por defecto padre/tutor
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final x = (v ?? '').trim();
    if (x.isEmpty) return 'Ingresa tu correo';
    if (!x.contains('@') || !x.contains('.')) return 'Correo no válido';
    return null;
  }

  Future<void> _onRegister() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) return;
    
    // Validar rol seleccionado
    if (_role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un rol'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validar que las contraseñas coincidan
    if (_passCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Obtener servicio de autenticación
    final auth = Provider.of<AuthService>(context, listen: false);
    
    // Intentar registrar
    final cred = await auth.registerWithEmail(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      fullName: _nameCtrl.text.trim(),
      role: _role!,
    );

    // Verificar si el widget sigue montado
    if (!mounted) return;

    // Manejar resultado
    if (cred != null) {
      // Registro exitoso - navegar según rol
      switch (_role!) {
        case UserRole.nanny:
          Navigator.pushReplacementNamed(context, Routes.nannyHome);
          break;
        case UserRole.admin:
          Navigator.pushReplacementNamed(context, Routes.adminDashboard);
          break;
        case UserRole.parent:
          Navigator.pushReplacementNamed(context, Routes.parentHome);
          break;
      }
    } else {
      // Registro fallido - mostrar error
      final errorMsg = auth.errorMessage ?? 'No se pudo registrar. Intenta de nuevo.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_role == UserRole.nanny ? 'Registro de Niñera' : 'Registro de Padre'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                
                // Título con punto decorativo
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Crea tu cuenta',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Completa los siguientes datos',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Selector de rol
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Padre/Tutor'),
                      selected: _role == UserRole.parent,
                      onSelected: (_) => setState(() => _role = UserRole.parent),
                      selectedColor: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                    ChoiceChip(
                      label: const Text('Niñera/Cuidador'),
                      selected: _role == UserRole.nanny,
                      onSelected: (_) => setState(() => _role = UserRole.nanny),
                      selectedColor: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Campo: Nombre completo
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa tu nombre'
                      : null,
                ),
                const SizedBox(height: 16),

                // Campo: Correo electrónico
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),

                // Campo: Contraseña
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure1,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure1
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscure1 = !_obscure1),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa una contraseña';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo: Confirmar contraseña
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscure2,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure2
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirma la contraseña';
                    if (v != _passCtrl.text) return 'No coincide con la contraseña';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // Botón de registro con estado de carga
                Consumer<AuthService>(
                  builder: (context, auth, _) {
                    return SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _onRegister,
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Registrarse',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Link a login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes cuenta?',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, Routes.login),
                      child: const Text('Inicia sesión'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}