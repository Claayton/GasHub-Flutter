import 'package:flutter/material.dart';
import 'orders_screen.dart';
import 'new_order_screen.dart';
import 'pending_screen.dart';
import 'dashboard_screen.dart';
import 'package:gasbub_flutter/widgets/app_drawer.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0; // Índice da tela atual

  // Lista de telas correspondentes a cada item do menu
  final List<Widget> _screens = [
    const OrdersScreen(),
    const NewOrderScreen(),
    const PendingScreen(),
    const DashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tela atual baseada no índice
      drawer: AppDrawer(),
      body: _screens[_currentIndex],
      
      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1e40af), // Azul DeepSeek
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Novo Pedido',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'À Receber',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }
}