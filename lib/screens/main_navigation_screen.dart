import 'package:flutter/material.dart';
import 'orders_screen.dart';
import 'new_order_screen.dart';
import 'pending_screen.dart';
import 'dashboard_screen.dart';
import 'package:gashub_flutter/widgets/menu.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ✅ FUNÇÃO PÚBLICA para mudar de aba
  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _screens = [
    const OrdersScreen(),
    const NewOrderScreen(),
    const PendingScreen(),
    const DashboardScreen(),
  ];

  final List<String> _screenTitles = [
    'Pedidos',
    'Novo Pedido',
    'À Receber',
    'Dashboard'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      appBar: AppBar(
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