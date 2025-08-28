import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // 👈 Certifique-se que está importado

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GasHub ⛽'),
        backgroundColor: Colors.orange,
      ),
      drawer: AppDrawer(), // ✅ SEM CONST!
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_gas_station, size: 80, color: Colors.orange),
            SizedBox(height: 20),
            Text(
              'Bem-vindo ao GasHub!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Encontre os melhores postos perto de você',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}