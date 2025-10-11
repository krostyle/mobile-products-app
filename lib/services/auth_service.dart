import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static Future<void> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'email': email,
            'name': name,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw 'El correo ya está registrado.';
      } else if (e.code == 'invalid-email') {
        throw 'El correo no es válido.';
      } else if (e.code == 'weak-password') {
        throw 'La contraseña es muy débil.';
      } else {
        throw 'Error al registrar: ${e.message}';
      }
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }

  static Future<void> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'No existe una cuenta con ese correo.';
        case 'wrong-password':
          throw 'La contraseña es incorrecta.';
        case 'invalid-email':
          throw 'El correo no es válido.';
        case 'user-disabled':
          throw 'La cuenta ha sido deshabilitada.';
        case 'invalid-credential':
          throw 'Credenciales inválidas o el correo no existe.';
        default:
          throw 'Error al iniciar sesión: ${e.message}';
      }
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }

  static Future<void> sendPasswordReset(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
}
