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
  final String? customerId;
  final String? createdByUserId;

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
    this.customerId,
    this.createdByUserId,
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
    String? customerId,
    String? createdByUserId,
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
      customerId: customerId ?? this.customerId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // 'id': id, // REMOVE esta linha - não salve o ID dentro do documento!
      'customerName': customerName,
      'customerAddress': customerAddress,
      'products': products.map((product) => product.toMap()).toList(),
      'orderDateTime': orderDateTime.toIso8601String(),
      'paymentMethod': paymentMethod.name,
      'dueDate': dueDate.toIso8601String(),
      'status': status.name,
      'pendingValue': pendingValue,
      'totalValue': totalValue,
      'userId': userId,
      'customerId': customerId,
      'createdByUserId': createdByUserId,
    };
  }

  factory OrderEntity.fromMap(Map<String, dynamic> map, String documentId) {
    return OrderEntity(
      id: documentId, // ✅ Usa o ID do documento como ID da entidade
      customerName: map['customerName'] ?? '',
      customerAddress: map['customerAddress'] ?? '',
      products: List<ProductEntity>.from(
        (map['products'] ?? []).map((item) => 
          // ✅ Usa o novo método que lê o ID de dentro dos dados do produto
          ProductEntity.fromMapWithIdInData(Map<String, dynamic>.from(item))
        ),
      ),
      orderDateTime: DateTime.parse(map['orderDateTime'] ?? DateTime.now().toIso8601String()),
      paymentMethod: PaymentMethods.values
          .firstWhere((e) => e.name == (map['paymentMethod'] ?? 'dinheiro')),
      dueDate: DateTime.parse(map['dueDate'] ?? DateTime.now().toIso8601String()),
      status: OrderStatus.values
          .firstWhere((e) => e.name == (map['status'] ?? 'pending')),
      pendingValue: (map['pendingValue'] ?? 0.0).toDouble(),
      totalValue: (map['totalValue'] ?? 0.0).toDouble(),
      userId: map['userId'] ?? '',
      customerId: map['customerId'],
      createdByUserId: map['createdByUserId'],
    );
  }
}