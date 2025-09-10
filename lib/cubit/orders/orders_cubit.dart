import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gasbub_flutter/models/order_entity.dart';
import 'package:gasbub_flutter/repositories/order_repository.dart';
import 'package:gasbub_flutter/cubit/orders/orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrderRepository _orderRepository;
  StreamSubscription? _ordersSubscription;

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

      final orders = await _orderRepository.getOrdersByDateRange(startOfDay, endOfDay);
      
      if (orders.isEmpty) {
        emit(OrdersEmpty());
      } else {
        emit(OrdersLoaded(orders));
      }
    } catch (e) {
      emit(OrdersError('Erro ao carregar pedidos: $e'));
    }
  }

  // Carregar pedidos fiados pendentes
  Future<void> loadPendingOrders() async {
    emit(OrdersLoading());
    try {
      final allOrders = await _orderRepository.getAllOrders();
      final pendingOrders = allOrders.where((order) => 
        order.paymentMethod == PaymentMethods.fiado && 
        order.pendingValue > 0 &&
        order.status == OrderStatus.pending
      ).toList();
      
      if (pendingOrders.isEmpty) {
        emit(OrdersEmpty());
      } else {
        // Ordenar por data de vencimento (mais próximos primeiro)
        pendingOrders.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        emit(OrdersLoaded(pendingOrders));
      }
    } catch (e) {
      emit(OrdersError('Erro ao carregar pedidos pendentes: $e'));
    }
  }

  // Stream em tempo real (opcional)
  Stream<List<OrderEntity>> watchTodayOrders() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return _orderRepository.watchOrdersByDateRange(startOfDay, endOfDay);
  }

  // Stream para pedidos fiados em tempo real
  Stream<List<OrderEntity>> watchPendingOrders() {
    return _orderRepository.getAllOrdersStream().map((allOrders) {
      return allOrders.where((order) => 
        order.paymentMethod == PaymentMethods.fiado && 
        order.pendingValue > 0 &&
        order.status == OrderStatus.pending
      ).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    });
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

  // Marcar pedido como pago (específico para fiados)
  Future<void> marcarComoPago(String orderId) async {
    try {
      final order = await _orderRepository.getOrder(orderId);
      if (order != null) {
        final updatedOrder = order.copyWith(
          status: OrderStatus.confirmed,
          pendingValue: 0.0, // Zera o valor pendente
        );
        await _orderRepository.updateOrder(orderId, updatedOrder);
        
        // Emitir sucesso sem recarregar (o stream vai atualizar automaticamente)
        emit(OrdersSuccess('Pedido marcado como pago com sucesso!'));
        
        // Voltar para o estado loaded após um breve delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (state is! OrdersLoaded) {
            loadPendingOrders();
          }
        });
      }
    } catch (e) {
      emit(OrdersError('Erro ao marcar pedido como pago: $e'));
    }
  }

  // Calcular total dos fiados
  double calcularTotalFiados() {
    if (state is OrdersLoaded) {
      final pedidos = (state as OrdersLoaded).orders;
      return pedidos.fold(0.0, (total, pedido) => total + pedido.pendingValue);
    }
    return 0.0;
  }

  // Verificar se tem pedidos fiados
  bool temPedidosFiados() {
    return state is OrdersLoaded && (state as OrdersLoaded).orders.isNotEmpty;
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}