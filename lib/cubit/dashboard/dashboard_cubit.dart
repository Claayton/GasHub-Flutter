import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gasbub_flutter/repositories/order_repository.dart';
import 'package:gasbub_flutter/cubit/dashboard/dashboard_state.dart';
import 'package:gasbub_flutter/models/order_entity.dart';

/// Enum para filtro de período
enum PeriodFilter { hoje, semana, mes }

/// Modelo para métricas do dashboard
@immutable
class DashboardMetrics {
  final int totalPedidos;
  final double totalValor;
  final int totalFiados;
  final int totalPagos;
  final double mediaPedido;
  final double taxaConversao; // percentual
  final List<OrderEntity> orders;
  final List<OrderEntity> recentOrders;
  final DateTimeRange period;

  const DashboardMetrics({
    required this.totalPedidos,
    required this.totalValor,
    required this.totalFiados,
    required this.totalPagos,
    required this.mediaPedido,
    required this.taxaConversao,
    required this.orders,
    required this.recentOrders,
    required this.period,
  });
}

class DashboardCubit extends Cubit<DashboardState> {
  final OrderRepository _orderRepository;

  DashboardCubit(this._orderRepository) : super(const DashboardInitial());

  /// Carrega métricas para um período específico
  Future<void> loadDashboardMetrics(DateTimeRange period) async {
    try {
      emit(const DashboardLoading());

      // Busca pedidos do período
      final orders = await _orderRepository.getOrdersByDateRange(
        period.start,
        period.end,
      );

      // Calcula as métricas
      final metrics = _calculateMetrics(orders, period);

      emit(DashboardLoaded(metrics: metrics));
    } catch (error) {
      emit(DashboardError('Erro ao carregar métricas: ${error.toString()}'));
    }
  }

  /// Atualiza métricas para o período atual (útil para refresh)
  Future<void> refreshDashboard(DateTimeRange currentPeriod) async {
    await loadDashboardMetrics(currentPeriod);
  }

  /// Método para calcular todas as métricas
  DashboardMetrics _calculateMetrics(
    List<OrderEntity> orders,
    DateTimeRange period,
  ) {
    if (orders.isEmpty) {
      return DashboardMetrics(
        totalPedidos: 0,
        totalValor: 0.0,
        totalFiados: 0,
        totalPagos: 0,
        mediaPedido: 0.0,
        taxaConversao: 0.0,
        orders: const [],
        recentOrders: const [],
        period: period,
      );
    }

    final totalPedidos = orders.length;
    final totalValor =
        orders.fold(0.0, (sum, order) => sum + order.totalValue);

    final fiados = orders
        .where((order) => order.paymentMethod == PaymentMethods.fiado)
        .toList();
    final totalFiados = fiados.length;

    final totalPagos = totalPedidos - totalFiados;
    final mediaPedido = totalValor / totalPedidos;
    final taxaConversao =
        totalPedidos > 0 ? ((totalPagos / totalPedidos) * 100) : 0.0;

    // Pedidos recentes (últimos 5 pedidos)
    final recentOrders = (List<OrderEntity>.from(orders)
          ..sort((a, b) => b.orderDateTime.compareTo(a.orderDateTime)))
        .take(5)
        .toList();

    return DashboardMetrics(
      totalPedidos: totalPedidos,
      totalValor: totalValor,
      totalFiados: totalFiados,
      totalPagos: totalPagos,
      mediaPedido: mediaPedido,
      taxaConversao: taxaConversao,
      orders: orders,
      recentOrders: recentOrders,
      period: period,
    );
  }

  /// Método para calcular período com base no filtro selecionado
  DateTimeRange getPeriodFromFilter(PeriodFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    switch (filter) {
      case PeriodFilter.hoje:
        return DateTimeRange(start: today, end: tomorrow);
      case PeriodFilter.semana:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 7)),
          end: tomorrow,
        );
      case PeriodFilter.mes:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: tomorrow,
        );
    }
  }
}
