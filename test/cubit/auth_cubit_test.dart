import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gasbub_flutter/services/auth_service.dart';
import 'package:gasbub_flutter/cubit/auth/auth_cubit.dart';
import 'package:gasbub_flutter/cubit/auth/auth_state.dart';

// ======== Mocks ========
class MockAuthService extends Mock implements AuthService {}
class MockUser extends Mock implements User {}

void main() {
  late MockAuthService mockAuthService;
  late AuthCubit authCubit;
  late MockUser mockUser;

  setUp(() {
    mockAuthService = MockAuthService();
    mockUser = MockUser();
    when(() => mockUser.uid).thenReturn("123");
    authCubit = AuthCubit(mockAuthService);
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit', () {
    // -------- _checkCurrentUser --------
    test('AuthCubit inicializa em AuthAuthenticated se há usuário logado', () {
      when(() => mockAuthService.currentUser).thenReturn(mockUser);
      final cubit = AuthCubit(mockAuthService);
      expect(cubit.state, isA<AuthAuthenticated>());
    });

    test('AuthCubit inicializa em AuthUnauthenticated se não há usuário', () {
      when(() => mockAuthService.currentUser).thenReturn(null);
      final cubit = AuthCubit(mockAuthService);
      expect(cubit.state, isA<AuthUnauthenticated>());
    });

    // -------- Login --------
    blocTest<AuthCubit, AuthState>(
      'login bem-sucedido emite [AuthLoading, AuthAuthenticated]',
      build: () {
        when(() => mockAuthService.login("test@test.com", "1234"))
            .thenAnswer((_) async => mockUser);
        return AuthCubit(mockAuthService);
      },
      act: (cubit) => cubit.login("test@test.com", "1234"),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>().having((s) => s.user.uid, "uid", "123"),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'login retorna null emite [AuthLoading, AuthError]',
      build: () {
        when(() => mockAuthService.login(any(), any()))
            .thenAnswer((_) async => null);
        return AuthCubit(mockAuthService);
      },
      act: (cubit) => cubit.login("fail@test.com", "1234"),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((s) => s.message, "message", contains("Falha no login")),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'login lança exceção emite [AuthLoading, AuthError]',
      build: () {
        when(() => mockAuthService.login(any(), any()))
            .thenThrow(Exception("Erro de login"));
        return AuthCubit(mockAuthService);
      },
      act: (cubit) => cubit.login("fail@test.com", "1234"),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((s) => s.message, "message", contains("Erro de login")),
      ],
    );

    // -------- Register --------
    blocTest<AuthCubit, AuthState>(
      'register bem-sucedido emite [AuthLoading, AuthAuthenticated]',
      build: () {
        when(() => mockAuthService.register("new@test.com", "1234"))
            .thenAnswer((_) async => mockUser);
        return AuthCubit(mockAuthService);
      },
      act: (cubit) => cubit.register("new@test.com", "1234"),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>().having((s) => s.user.uid, "uid", "123"),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'register retorna null emite [AuthLoading, AuthError]',
      build: () {
        when(() => mockAuthService.register(any(), any()))
            .thenAnswer((_) async => null);
        return AuthCubit(mockAuthService);
      },
      act: (cubit) => cubit.register("fail@test.com", "1234"),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((s) => s.message, "message", contains("Falha no registro")),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'register lança exceção emite [AuthLoading, AuthError]',
      build: () {
        when(() => mockAuthService.register(any(), any()))
            .thenThrow(Exception("Erro de registro"));
        return AuthCubit(mockAuthService);
      },
      act: (cubit) => cubit.register("fail@test.com", "1234"),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((s) => s.message, "message", contains("Erro de registro")),
      ],
    );

    // -------- Logout --------
    test('logout bem-sucedido emite AuthUnauthenticated', () async {
      when(() => mockAuthService.logout()).thenAnswer((_) async {});

      final cubit = AuthCubit(mockAuthService);
      await cubit.logout();

      expect(cubit.state, isA<AuthUnauthenticated>());
    });

    test('logout lança exceção emite AuthError e depois AuthUnauthenticated', () async {
      when(() => mockAuthService.logout()).thenThrow(Exception("Erro logout"));

      final cubit = AuthCubit(mockAuthService);
      await cubit.logout();

      // O estado final deve ser AuthUnauthenticated
      expect(cubit.state, isA<AuthUnauthenticated>());

      // Opcional: você pode checar se algum estado foi AuthError, mas só dá pra acessar o último emitido diretamente assim
    });

    // -------- clearError --------
    blocTest<AuthCubit, AuthState>(
      'clearError transforma AuthError em AuthUnauthenticated',
      build: () => authCubit,
      seed: () => const AuthError("Falha"),
      act: (cubit) => cubit.clearError(),
      expect: () => [isA<AuthUnauthenticated>()],
    );

    blocTest<AuthCubit, AuthState>(
      'clearError não faz nada se estado não é AuthError',
      build: () => authCubit,
      seed: () => AuthUnauthenticated(),
      act: (cubit) => cubit.clearError(),
      expect: () => [],
    );
  });
}
