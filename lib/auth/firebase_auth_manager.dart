import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:divelogtest/auth/auth_manager.dart';
import 'package:logging/logging.dart';

class FirebaseAuthManager extends AuthManager with EmailSignInManager {
  static final Logger _log = Logger('FirebaseAuthManager');
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  @override
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  @override
  firebase_auth.User? get currentUser => _auth.currentUser;

  @override
  Future<firebase_auth.User?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleAuthError(context, e, 'sign in');
      return null;
    } catch (e) {
      _log.severe('Unexpected sign in error', e);
      _showSnackbar(context, 'Error inesperado al iniciar sesión');
      return null;
    }
  }

  void _handleAuthError(
      BuildContext context, firebase_auth.FirebaseAuthException e, String op) {
    _log.warning('Firebase $op error: ${e.code} - ${e.message}');
    final errorMessage = _getFriendlyErrorMessage(e.code);
    _showSnackbar(context, errorMessage);
  }

  void _showSnackbar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String _getFriendlyErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No se encontró una cuenta con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      default:
        return 'Ha ocurrido un error de autenticación';
    }
  }

  @override
  Future<firebase_auth.User?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleAuthError(context, e, 'registration');
      return null;
    } catch (e) {
      _log.severe('Unexpected registration error', e);
      _showSnackbar(context, 'Error inesperado al crear cuenta');
      return null;
    }
  }

  @override
  Future signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      _log.severe('Sign out error', e);
      rethrow;
    }
  }

  @override
  Future deleteUser(BuildContext context) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');
      await user.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleAuthError(context, e, 'delete user');
      rethrow;
    } catch (e) {
      _log.severe('Unexpected delete user error', e);
      _showSnackbar(context, 'Error inesperado al eliminar cuenta');
      rethrow;
    }
  }

  @override
  Future updateEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');
      await user.verifyBeforeUpdateEmail(email);
      _showSnackbar(context, 'Se ha enviado un correo de verificación');
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleAuthError(context, e, 'update email');
      rethrow;
    } catch (e) {
      _log.severe('Unexpected update email error', e);
      _showSnackbar(context, 'Error inesperado al actualizar correo');
      rethrow;
    }
  }

  @override
  Future resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSnackbar(
          context, 'Se ha enviado un correo para restablecer tu contraseña');
    } on firebase_auth.FirebaseAuthException catch (e) {
      _handleAuthError(context, e, 'reset password');
      rethrow;
    } catch (e) {
      _log.severe('Unexpected reset password error', e);
      _showSnackbar(context, 'Error inesperado al enviar correo');
      rethrow;
    }
  }
}
