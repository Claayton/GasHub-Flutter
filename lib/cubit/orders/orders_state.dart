import 'package:gasbub_flutter/models/order_entity.dart';

abstract class OrdersState {}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  OrdersLoaded(this.orders);
}

class OrdersEmpty extends OrdersState {}

class OrdersError extends OrdersState {
  final String message;
  OrdersError(this.message);
}