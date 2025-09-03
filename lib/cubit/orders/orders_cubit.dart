import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gasbub_flutter/models/order_entity.dart';
import 'package:gasbub_flutter/repositories/order_repository.dart';
import 'package:gasbub_flutter/cubit/orders/orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrderRepository _orderRepository;

  OrdersCubit(this._orderRepository) : super(OrdersInitial());

  Future<void> createOrder(OrderEntity order) async {
    try {
      await _orderRepository.createOrder(order);
      // Recarrega a lista após criar
      await loadTodayOrders();
    } catch (e) {
      emit(OrdersError('Erro ao criar pedido: $e'));
    }
  }

  // Carregar pedidos do dia
  Future<void> loadTodayOrders() async {
    emit(OrdersLoading());
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      // Precisamos adicionar este método no OrderRepository
      final orders = await _orderRepository.getOrdersByDateRange(startOfDay, endOfDay);
      
      if (orders.isEmpty) {
        emit(OrdersEmpty());
      } else {
        // Já ordenados por data (mais recente primeiro)
        emit(OrdersLoaded(orders));
      }
    } catch (e) {
      emit(OrdersError('Erro ao carregar pedidos: $e'));
    }
  }

  // Stream em tempo real (opcional)
  Stream<List<OrderEntity>> watchTodayOrders() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    // Precisamos adicionar este método também
    return _orderRepository.watchOrdersByDateRange(startOfDay, endOfDay);
  }

  // Atualizar status do pedido
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final order = await _orderRepository.getOrder(orderId);
      if (order != null) {
        final updatedOrder = order.copyWith(status: newStatus);
        await _orderRepository.updateOrder(orderId, updatedOrder);
        // Recarrega a lista
        await loadTodayOrders();
      }
    } catch (e) {
      emit(OrdersError('Erro ao atualizar pedido: $e'));
    }
  }
}