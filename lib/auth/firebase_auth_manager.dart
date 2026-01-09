import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:divelogtest/auth/auth_manager.dart';

class FirebaseAuthManager extends AuthManager with EmailSignInManager {
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
      debugPrint('Firebase sign in error: ${e.code} - ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No se encontró una cuenta con este correo';
          break;
        case 'wrong-password':
          errorMessage = 'Contraseña incorrecta';
          break;
        case 'invalid-email':
          errorMessage = 'Correo electrónico inválido';
          break;
        case 'user-disabled':
          errorMessage = 'Esta cuenta ha sido deshabilitada';
          break;
        default:
          errorMessage = 'Error al iniciar sesión: ${e.message}';
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Unexpected sign in error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error inesperado al iniciar sesión')),
        );
      }
      return null;
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
      debugPrint('Firebase registration error: ${e.code} - ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Este correo ya está registrado';
          break;
        case 'invalid-email':
          errorMessage = 'Correo electrónico inválido';
          break;
        case 'weak-password':
          errorMessage = 'La contraseña debe tener al menos 6 caracteres';
          break;
        case 'operation-not-allowed':
          errorMessage = 'El registro con correo no está habilitado';
          break;
        default:
          errorMessage = 'Error al crear cuenta: ${e.message}';
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Unexpected registration error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error inesperado al crear cuenta')),
        );
      }
      return null;
    }
  }

  @override
  Future signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  @override
  Future deleteUser(BuildContext context) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }
      await user.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Delete user error: ${e.code} - ${e.message}');
      String errorMessage;
      if (e.code == 'requires-recent-login') {
        errorMessage = 'Debes iniciar sesión nuevamente para eliminar tu cuenta';
      } else {
        errorMessage = 'Error al eliminar cuenta: ${e.message}';
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
      rethrow;
    } catch (e) {
      debugPrint('Unexpected delete user error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error inesperado al eliminar cuenta')),
        );
      }
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
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }
      await user.verifyBeforeUpdateEmail(email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se ha enviado un correo de verificación'),
          ),
        );
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Update email error: ${e.code} - ${e.message}');
      String errorMessage;
      if (e.code == 'requires-recent-login') {
        errorMessage = 'Debes iniciar sesión nuevamente para cambiar tu correo';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Este correo ya está en uso';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Correo electrónico inválido';
      } else {
        errorMessage = 'Error al actualizar correo: ${e.message}';
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
      rethrow;
    } catch (e) {
      debugPrint('Unexpected update email error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error inesperado al actualizar correo')),
        );
      }
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se ha enviado un correo para restablecer tu contraseña'),
          ),
        );
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Reset password error: ${e.code} - ${e.message}');
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No se encontró una cuenta con este correo';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Correo electrónico inválido';
      } else {
        errorMessage = 'Error al enviar correo: ${e.message}';
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
      rethrow;
    } catch (e) {
      debugPrint('Unexpected reset password error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error inesperado al enviar correo')),
        );
      }
      rethrow;
    }
  }
}
