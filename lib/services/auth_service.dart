import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  final FirebaseAuth _firebaseAuth;
  
  AuthService({FirebaseAuth? firebaseAuth}) 
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Login direto
  Future<User?> login(String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
      return result.user;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Registro direto  
  Future<User?> register(String email, String password) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // Usuário atual
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream de mudanças de auth
  Stream<User?> get userChanges => _firebaseAuth.userChanges();

  // Tratamento de errors
  String _handleError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Email inválido';
        case 'user-disabled':
          return 'Usuário desativado';
        case 'user-not-found':
          return 'Usuário não encontrado';
        case 'wrong-password':
          return 'Senha incorreta';
        case 'email-already-in-use':
          return 'Email já está em uso';
        case 'weak-password':
          return 'Senha muito fraca';
        default:
          return 'Erro de autenticação';
      }
    }
    return 'Erro desconhecido';
  }
}