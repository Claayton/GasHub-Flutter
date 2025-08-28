import 'package:flutter/material.dart';

class NewOrderScreen extends StatelessWidget {
  const NewOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Pedido'),
      ),
      body: const Center(
        child: Text('Formulário para criar novo pedido será exibido aqui'),
      ),
    );
  }
}