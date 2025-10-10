import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final pass = TextEditingController();
  bool isLogin = true;
  bool loading = false;

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> _ensureUserDoc(User user) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snap = await ref.get();
    final fallbackName = (user.email ?? '').split('@').first;
    if (!snap.exists) {
      await ref.set({
        'displayName': fallbackName,
        // 'photoUrl': null, // sin Storage por ahora
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Asegura que al menos tenga email y updatedAt
      await ref.set({
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => loading = true);
    try {
      final auth = FirebaseAuth.instance;
      final mail = email.text.trim();
      final pwd = pass.text;

      if (isLogin) {
        final cred = await auth.signInWithEmailAndPassword(email: mail, password: pwd);
        await _ensureUserDoc(cred.user!);
      } else {
        final cred = await auth.createUserWithEmailAndPassword(email: mail, password: pwd);
        // Crea doc con nombre inicial basado en el email
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'displayName': mail.split('@').first,
          // 'photoUrl': null, // sin Storage por ahora
          'email': cred.user!.email,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      // StreamBuilder en main.dart redirigirá automáticamente
    } on FirebaseAuthException catch (e) {
      final msg = e.message ?? 'Error de autenticación';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ocurrió un error')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Ingresa tu email';
    if (!value.contains('@') || !value.contains('.')) return 'Email no válido';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = v ?? '';
    if (value.isEmpty) return 'Ingresa tu contraseña';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Iniciar sesión' : 'Crear cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              validator: _validateEmail,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: pass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
              validator: _validatePassword,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(isLogin ? 'Entrar' : 'Registrarme'),
              ),
            ),
            TextButton(
              onPressed: loading ? null : () => setState(() => isLogin = !isLogin),
              child: Text(isLogin ? '¿No tienes cuenta? Regístrate' : '¿Ya tienes cuenta? Inicia sesión'),
            ),
          ]),
        ),
      ),
    );
  }
}