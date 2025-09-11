import 'package:gashub_flutter/models/product_entity.dart';

enum OrderStatus { pending, confirmed }
enum PaymentMethods { pix, debito, credito, dinheiro, fiado }

class OrderEntity {
  final String id;
  final String customerName;
  final String customerAddress;
  final List<ProductEntity> products;
  final DateTime orderDateTime;
  final PaymentMethods paymentMethod;
  final DateTime dueDate;
  final OrderStatus status;
  final double pendingValue;
  final double totalValue;
  final String userId;

  OrderEntity({
    required this.id,
    required this.customerName,
    required this.customerAddress,
    required this.products,
    required this.orderDateTime,
    required this.paymentMethod,
    required this.dueDate,
    required this.status,
    required this.pendingValue,
    required this.totalValue,
    required this.userId,
  });

  OrderEntity copyWith({
    String? id,
    String? customerName,
    String? customerAddress,
    List<ProductEntity>? products,
    DateTime? orderDateTime,
    PaymentMethods? paymentMethod,
    DateTime? dueDate,
    OrderStatus? status,
    double? pendingValue,
    double? totalValue,
    String? userId,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      products: products ?? this.products,
      orderDateTime: orderDateTime ?? this.orderDateTime,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      pendingValue: pendingValue ?? this.pendingValue,
      totalValue: totalValue ?? this.totalValue,
      userId: userId ?? this.userId,
    );
  }
}
