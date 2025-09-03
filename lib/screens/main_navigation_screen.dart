import 'package:flutter/material.dart';
import 'orders_screen.dart';
import 'new_order_screen.dart';
import 'pending_screen.dart';
import 'dashboard_screen.dart';
import 'package:gasbub_flutter/widgets/menu.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0; // Índice da tela atual
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // ← ADICIONE ISSO

  // Lista de telas correspondentes a cada item do menu
  final List<Widget> _screens = [
    const OrdersScreen(),
    const NewOrderScreen(),
    const PendingScreen(),
    const DashboardScreen(),
  ];

  // Títulos para cada tab
  final List<String> _screenTitles = [
    'Pedidos',
    'Novo Pedido',
    'À Receber',
    'Dashboard'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // ← ADICIONE ISSO
      drawer: const AppDrawer(),
      appBar: AppBar( // ← ADICIONE ESTA AppBar
        title: Text(_screenTitles[_currentIndex]),
        backgroundColor: const Color(0xFF1e40af),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
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
        selectedItemColor: const Color(0xFF1e40af),
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