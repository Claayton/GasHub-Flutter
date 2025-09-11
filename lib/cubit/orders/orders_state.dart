import 'package:gashub_flutter/models/order_entity.dart';

abstract class OrdersState {}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  OrdersLoaded(this.orders);
}

class OrdersEmpty extends OrdersState {}

class OrdersSuccess extends OrdersState {
  final String message;
  OrdersSuccess(this.message);
}

class OrdersError extends OrdersState {
  final String message;
  OrdersError(this.message);
}