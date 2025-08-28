import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart'; // 👈 Certifique-se de importar

void main() {
  runApp(const GasHubApp());
}

class GasHubApp extends StatelessWidget {
  const GasHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GasHub - Gestão de Pedidos',
      theme: ThemeData(
        // PALETA AZUL DEEPSEEK - NOVA IDENTIDADE
        primaryColor: const Color(0xFF1e40af),     // Azul principal
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1e40af),      // Azul DeepSeek
          primary: const Color(0xFF1e40af),        // Azul principal
          secondary: const Color(0xFF3b82f6),      // Azul secundário
          background: const Color(0xFFf8fafc),     // Fundo suave
        ),
        scaffoldBackgroundColor: const Color(0xFFf8fafc),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1e40af),      // AppBar azul
          foregroundColor: Colors.white,           // Texto branco
          elevation: 2,
        ),
        useMaterial3: true,
      ),
      home: MainNavigationScreen(), // ✅✅✅ SEM CONST AGORA!
      debugShowCheckedModeBanner: false,
    );
  }
}