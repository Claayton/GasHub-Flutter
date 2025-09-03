import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gasbub_flutter/cubit/orders/orders_cubit.dart';
import 'package:gasbub_flutter/cubit/orders/orders_state.dart';
import 'package:gasbub_flutter/screens/main_navigation_screen.dart';
import 'package:gasbub_flutter/widgets/order_card.dart';
import 'package:gasbub_flutter/repositories/order_repository.dart';
import 'package:gasbub_flutter/models/order_entity.dart';
import 'package:gasbub_flutter/screens/new_order_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrdersCubit(
        OrderRepository(), // Seu repository já implementado
      )..loadTodayOrders(), // Carrega os pedidos automaticamente
      child: Scaffold(
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            return _buildBody(context, state);
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // ✅ ACESSA O MAINNAVIGATIONSCREEN E MUDA PARA NOVO PEDIDO
            final mainState = context.findAncestorStateOfType<MainNavigationScreenState>();
            mainState?.changeTab(1); // 1 = índice do Novo Pedido
          },
          backgroundColor: const Color(0xFF1e40af),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrdersState state) {
    if (state is OrdersLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is OrdersError) {
      return Center(
        child: Text(
          state.message,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    } else if (state is OrdersEmpty) {
      return const Center(
        child: Text(
          'Nenhum pedido hoje!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    } else if (state is OrdersLoaded) {
      return _buildOrdersList(context, state.orders);
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildOrdersList(BuildContext context, List<OrderEntity> orders) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrdersCubit>().loadTodayOrders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderCard(
            order: order,
            onTap: () {
              // TODO: Navegar para detalhes do pedido
              print('Abrir detalhes do pedido: ${order.id}');
            },
          );
        },
      ),
    );
  }
}