import 'package:flutter/material.dart';

class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos a Receber'),
      ),
      body: const Center(
        child: Text('Pedidos pendentes serão exibidos aqui'),
      ),
    );
  }
}