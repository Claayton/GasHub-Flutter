import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gashub_flutter/services/auth_service.dart';

// Mocks com Mocktail
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late AuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    
    authService = AuthService(firebaseAuth: mockFirebaseAuth);
  });

  group('Login', () {
    test('Deve retornar User quando login for bem-sucedido', () async {
      // Arrange
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@email.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);
      
      when(() => mockUserCredential.user).thenReturn(mockUser);

      // Act
      final result = await authService.login('test@email.com', 'password123');

      // Assert
      expect(result, equals(mockUser));
      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@email.com',
        password: 'password123',
      )).called(1);
    });

    test('Deve lançar erro quando login falhar', () async {
      // Arrange
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@email.com',
        password: 'wrongpassword',
      )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      // Act & Assert
      expect(
        () async => await authService.login('test@email.com', 'wrongpassword'),
        throwsA(isA<String>()),
      );
    });
  });

  group('Register', () {
    test('Deve retornar User quando registro for bem-sucedido', () async {
      // Arrange
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'new@email.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);
      
      when(() => mockUserCredential.user).thenReturn(mockUser);

      // Act
      final result = await authService.register('new@email.com', 'password123');

      // Assert
      expect(result, equals(mockUser));
      verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'new@email.com',
        password: 'password123',
      )).called(1);
    });

    test('Deve lançar erro quando email já estiver em uso', () async {
      // Arrange
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'existing@email.com',
        password: 'password123',
      )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      // Act & Assert
      expect(
        () async => await authService.register('existing@email.com', 'password123'),
        throwsA('Email já está em uso'),
      );
    });
  });

  group('Logout', () {
    test('Deve chamar signOut corretamente', () async {
      // Arrange
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async => {});

      // Act
      await authService.logout();

      // Assert
      verify(() => mockFirebaseAuth.signOut()).called(1);
    });
  });

  group('Current User', () {
    test('Deve retornar usuário atual quando logado', () {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Act
      final result = authService.currentUser;

      // Assert
      expect(result, equals(mockUser));
    });

    test('Deve retornar null quando não logado', () {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = authService.currentUser;

      // Assert
      expect(result, isNull);
    });
  });

  group('User Changes Stream', () {
    test('Deve retornar stream de mudanças de usuário', () {
      // Arrange
      final stream = Stream<User?>.fromIterable([mockUser, null]);
      when(() => mockFirebaseAuth.userChanges()).thenAnswer((_) => stream);

      // Act
      final result = authService.userChanges;

      // Assert
      expect(result, equals(stream));
    });
  });

  group('Error Handling - Teste Indireto', () {
    test('Deve retornar "Senha muito fraca" para weak-password', () async {
      // Arrange
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'test@email.com',
        password: 'weak',
      )).thenThrow(FirebaseAuthException(code: 'weak-password'));

      // Act & Assert
      expect(
        () async => await authService.register('test@email.com', 'weak'),
        throwsA('Senha muito fraca'),
      );
    });

    test('Deve retornar "Email já está em uso" para email-already-in-use', () async {
      // Arrange
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'existing@email.com',
        password: 'password123',
      )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      // Act & Assert
      expect(
        () async => await authService.register('existing@email.com', 'password123'),
        throwsA('Email já está em uso'),
      );
    });

    test('Deve retornar "Email inválido" para invalid-email', () async {
      // Arrange
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'invalid-email',
        password: 'password123',
      )).thenThrow(FirebaseAuthException(code: 'invalid-email'));

      // Act & Assert
      expect(
        () async => await authService.login('invalid-email', 'password123'),
        throwsA('Email inválido'),
      );
    });

    test('Deve retornar "Erro de autenticação" para erro desconhecido do Firebase', () async {
      // Arrange
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@email.com',
        password: 'password123',
      )).thenThrow(FirebaseAuthException(code: 'unknown-error'));

      // Act & Assert
      expect(
        () async => await authService.login('test@email.com', 'password123'),
        throwsA('Erro de autenticação'),
      );
    });

    test('Deve retornar "Erro desconhecido" para exceções não Firebase', () async {
      // Arrange
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@email.com',
        password: 'password123',
      )).thenThrow(Exception('Erro genérico'));

      // Act & Assert
      expect(
        () async => await authService.login('test@email.com', 'password123'),
        throwsA('Erro desconhecido'),
      );
    });
  });
}