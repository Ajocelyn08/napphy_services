import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:napphy_services/models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  UserModel? _currentUserModel;
  UserModel? get currentUserModel => _currentUserModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user != null) {
      await _ensureUserDoc(user);
      await loadUserData(user.uid);
    } else {
      _currentUserModel = null;
    }
    notifyListeners();
  }

  Future<void> loadUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        _currentUserModel = UserModel.fromFirestore(doc);
      } else {
        _currentUserModel = null;
      }
    } catch (e) {
      _errorMessage = 'Error al cargar datos del usuario: $e';
      debugPrint('Error en loadUserData: $e');
    }
    notifyListeners();
  }

  Future<void> _ensureUserDoc(User user, {String? fullName, UserRole? role}) async {
    try {
      final ref = _firestore.collection('users').doc(user.uid);
      final snap = await ref.get();
      final fallbackName = fullName ?? user.displayName ?? (user.email ?? '').split('@').first;

      final base = <String, dynamic>{
        'id': user.uid,
        'email': user.email ?? '',
        'fullName': fallbackName,
        'updatedAt': Timestamp.now(),
      };
      if (role != null) base['role'] = role.name;

      if (!snap.exists) {
        await ref.set({
          ...base,
          'createdAt': Timestamp.now(),
          'photoUrl': null,
        });
      } else {
        await ref.update(base);
      }
    } catch (e) {
      debugPrint('Error en _ensureUserDoc: $e');
    }
  }

  // Registro con email y contraseña
  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final userName = fullName.trim().isEmpty ? email.split('@').first : fullName.trim();

      // Crea documento de usuario en Firestore
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'id': cred.user!.uid,
        'email': email.trim(),
        'fullName': userName,
        'role': role.name,
        'photoUrl': null,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      // Actualiza displayName en Firebase Auth
      await cred.user!.updateDisplayName(userName);

      await loadUserData(cred.user!.uid);

      _isLoading = false;
      notifyListeners();
      return cred;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getAuthErrorMessage(e.code);
      notifyListeners();
      debugPrint('FirebaseAuthException en registro: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error desconocido: $e';
      notifyListeners();
      debugPrint('Error en registerWithEmail: $e');
      return null;
    }
  }

  // Inicio de sesión con email y contraseña
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Asegura doc y actualiza lastLogin
      await _ensureUserDoc(cred.user!);
      await _firestore.collection('users').doc(cred.user!.uid).update({
        'lastLogin': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      await loadUserData(cred.user!.uid);

      _isLoading = false;
      notifyListeners();
      return cred;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getAuthErrorMessage(e.code);
      notifyListeners();
      debugPrint('FirebaseAuthException en login: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error desconocido: $e';
      notifyListeners();
      debugPrint('Error en signInWithEmail: $e');
      return null;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUserModel = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión: $e';
      notifyListeners();
    }
  }

  // Enviar email de verificación
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      _errorMessage = 'Error al enviar email de verificación: $e';
      notifyListeners();
    }
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      _errorMessage = 'Error al enviar email de restablecimiento: $e';
      notifyListeners();
    }
  }

  // Actualizar perfil de usuario
  Future<void> updateUserProfile({
    String? fullName,
    String? photoUrl,
  }) async {
    try {
      if (currentUser == null) return;

      final updates = <String, dynamic>{};
      if (fullName != null && fullName.trim().isNotEmpty) {
        updates['fullName'] = fullName.trim();
      }
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      updates['updatedAt'] = Timestamp.now();

      await _firestore.collection('users').doc(currentUser!.uid).update(updates);

      await loadUserData(currentUser!.uid);
    } catch (e) {
      _errorMessage = 'Error al actualizar perfil: $e';
      notifyListeners();
    }
  }

  // Mensajes de error en español
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este correo electrónico ya está registrado.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'operation-not-allowed':
        return 'Operación no permitida.';
      case 'weak-password':
        return 'La contraseña es muy débil.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'user-not-found':
        return 'No se encontró un usuario con este correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde.';
      case 'invalid-credential':
        return 'Credenciales inválidas. Verifica tu correo y contraseña.';
      default:
        return 'Error de autenticación: $code';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}