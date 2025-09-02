import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseConfig {
  static late final FirebaseApp app;
  static late final FirebaseAuth auth;
  static late final FirebaseFirestore firestore;

  static Future<void> initialize() async {
    try {
      app = await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: const String.fromEnvironment('FIREBASE_API_KEY'),
          authDomain: const String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
          projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
          storageBucket: const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
          messagingSenderId: const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
          appId: const String.fromEnvironment('FIREBASE_APP_ID'),
          measurementId: const String.fromEnvironment('FIREBASE_MEASUREMENT_ID'),
        ),
      );

      auth = FirebaseAuth.instance;
      firestore = FirebaseFirestore.instance;

      // Verificação de inicialização
      if (app.name.isEmpty || auth.app.name.isEmpty) {
        throw Exception('Firebase initialization error!');
      }

    } catch (e) {
      rethrow;
    }
  }

  // Helper para verificar se as variáveis estão definidas
  static void checkEnvironmentVariables() {
    final missingVars = <String>[];

    // Verifica cada variável individualmente com string literal
    if (const String.fromEnvironment('FIREBASE_API_KEY').isEmpty) {
      missingVars.add('FIREBASE_API_KEY');
    }
    if (const String.fromEnvironment('FIREBASE_AUTH_DOMAIN').isEmpty) {
      missingVars.add('FIREBASE_AUTH_DOMAIN');
    }
    if (const String.fromEnvironment('FIREBASE_PROJECT_ID').isEmpty) {
      missingVars.add('FIREBASE_PROJECT_ID');
    }
    if (const String.fromEnvironment('FIREBASE_STORAGE_BUCKET').isEmpty) {
      missingVars.add('FIREBASE_STORAGE_BUCKET');
    }
    if (const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID').isEmpty) {
      missingVars.add('FIREBASE_MESSAGING_SENDER_ID');
    }
    if (const String.fromEnvironment('FIREBASE_APP_ID').isEmpty) {
      missingVars.add('FIREBASE_APP_ID');
    }
    if (const String.fromEnvironment('FIREBASE_MEASUREMENT_ID').isEmpty) {
      missingVars.add('FIREBASE_MEASUREMENT_ID');
    }

    if (missingVars.isNotEmpty) {
      throw Exception(
        'Variáveis de ambiente Firebase não definidas: ${missingVars.join(', ')}\n'
        'Execute com: flutter run --dart-define=FIREBASE_API_KEY=sua_chave ...'
      );
    }
  }
}