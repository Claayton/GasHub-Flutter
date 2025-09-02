import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gasbub_flutter/services/auth_service.dart';
import 'auth_state.dart'; // 👈 Import do mesmo diretório

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  
  AuthCubit(this._authService) : super(AuthInitial()) {
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      emit(AuthAuthenticated(currentUser));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Falha no login'));
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        emit(AuthError(e.message ?? 'Erro de autenticação'));
      } else {
        emit(AuthError('Erro inesperado: $e'));
      }
    }
  }

  Future<void> register(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authService.register(email, password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Falha no registro'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
      try {
      await _authService.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  void clearError() {
    if (state is AuthError) {
      emit(AuthUnauthenticated());
    }
  }
}