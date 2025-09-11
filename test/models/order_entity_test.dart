import 'package:flutter_test/flutter_test.dart';
import 'package:gashub_flutter/models/product_entity.dart';
import 'package:gashub_flutter/models/order_entity.dart';

void main() {
  // Mock products for testing
  final products = [
      ProductEntity(
      id: '1',
      name: 'Gás 13kg',
      price: 120.00,
      description: 'Botijão P13',
      stockQuantity: 50,
    ),
    ProductEntity(
      id: '2',
      name: 'Gas 45kg',
      price: 250.0,
      description: 'Botijão de gás 45kg',
      stockQuantity: 50,
    ),
  ];

  // Sample order data for testing
  final orderDateTime = DateTime(2024, 1, 15, 10, 30);
  final dueDate = DateTime(2024, 1, 20, 18, 0);

  final order = OrderEntity(
    id: 'order-123',
    customerName: 'João Silva',
    customerAddress: 'Rua das Flores, 123 - Centro',
    products: products,
    orderDateTime: orderDateTime,
    paymentMethod: PaymentMethods.credito,
    dueDate: dueDate,
    status: OrderStatus.pending,
    pendingValue: 330.0,
    totalValue: 330.0,
    userId: 'user-456',
  );

  group('OrderEntity Tests', () {
    test('should create an OrderEntity with correct values', () {
      expect(order.id, 'order-123');
      expect(order.customerName, 'João Silva');
      expect(order.customerAddress, 'Rua das Flores, 123 - Centro');
      expect(order.products, products);
      expect(order.orderDateTime, orderDateTime);
      expect(order.paymentMethod, PaymentMethods.credito);
      expect(order.dueDate, dueDate);
      expect(order.status, OrderStatus.pending);
      expect(order.pendingValue, 330.0);
      expect(order.totalValue, 330.0);
      expect(order.userId, 'user-456');
    });

    test('should create an OrderEntity with confirmed status', () {
      final confirmedOrder = OrderEntity(
        id: 'order-456',
        customerName: 'Maria Santos',
        customerAddress: 'Av. Principal, 456 - Bairro Novo',
        products: [products[0]],
        orderDateTime: orderDateTime,
        paymentMethod: PaymentMethods.dinheiro,
        dueDate: dueDate,
        status: OrderStatus.confirmed,
        pendingValue: 0.0,
        totalValue: 80.0,
        userId: 'user-789',
      );

      expect(confirmedOrder.status, OrderStatus.confirmed);
      expect(confirmedOrder.pendingValue, 0.0);
      expect(confirmedOrder.totalValue, 80.0);
      expect(confirmedOrder.products.length, 1);
    });

    test('copyWith should create a new instance with updated values', () {
      final updatedOrder = order.copyWith(
        customerName: 'Carlos Oliveira',
        status: OrderStatus.confirmed,
        pendingValue: 0.0,
      );

      // Updated fields
      expect(updatedOrder.customerName, 'Carlos Oliveira');
      expect(updatedOrder.status, OrderStatus.confirmed);
      expect(updatedOrder.pendingValue, 0.0);

      // Unchanged fields
      expect(updatedOrder.id, order.id);
      expect(updatedOrder.customerAddress, order.customerAddress);
      expect(updatedOrder.products, order.products);
      expect(updatedOrder.orderDateTime, order.orderDateTime);
      expect(updatedOrder.paymentMethod, order.paymentMethod);
      expect(updatedOrder.dueDate, order.dueDate);
      expect(updatedOrder.totalValue, order.totalValue);
      expect(updatedOrder.userId, order.userId);
    });

    test('copyWith should handle partial updates', () {
      final partialUpdate = order.copyWith(
        paymentMethod: PaymentMethods.pix,
      );

      expect(partialUpdate.paymentMethod, PaymentMethods.pix);

      // All other fields should remain the same
      expect(partialUpdate.id, order.id);
      expect(partialUpdate.customerName, order.customerName);
      expect(partialUpdate.customerAddress, order.customerAddress);
      expect(partialUpdate.products, order.products);
      expect(partialUpdate.orderDateTime, order.orderDateTime);
      expect(partialUpdate.dueDate, order.dueDate);
      expect(partialUpdate.status, order.status);
      expect(partialUpdate.pendingValue, order.pendingValue);
      expect(partialUpdate.totalValue, order.totalValue);
      expect(partialUpdate.userId, order.userId);
    });

    test('copyWith should handle empty products list', () {
      final emptyProductsOrder = order.copyWith(
        products: [],
        totalValue: 0.0,
        pendingValue: 0.0,
      );

      expect(emptyProductsOrder.products, isEmpty);
      expect(emptyProductsOrder.totalValue, 0.0);
      expect(emptyProductsOrder.pendingValue, 0.0);
    });

    test('should handle different payment methods', () {
      final pixOrder = order.copyWith(paymentMethod: PaymentMethods.pix);
      final moneyOrder = order.copyWith(paymentMethod: PaymentMethods.dinheiro);
      final cardOrder = order.copyWith(paymentMethod: PaymentMethods.debito);

      expect(pixOrder.paymentMethod, PaymentMethods.pix);
      expect(moneyOrder.paymentMethod, PaymentMethods.dinheiro);
      expect(cardOrder.paymentMethod, PaymentMethods.debito);
    });

    test('should handle different date times', () {
      final newOrderDateTime = DateTime(2024, 2, 1, 14, 0);
      final newDueDate = DateTime(2024, 2, 5, 12, 0);

      final updatedOrder = order.copyWith(
        orderDateTime: newOrderDateTime,
        dueDate: newDueDate,
      );

      expect(updatedOrder.orderDateTime, newOrderDateTime);
      expect(updatedOrder.dueDate, newDueDate);
    });

    test('should handle zero values for pendingValue and totalValue', () {
      final zeroValueOrder = order.copyWith(
        pendingValue: 0.0,
        totalValue: 0.0,
      );

      expect(zeroValueOrder.pendingValue, 0.0);
      expect(zeroValueOrder.totalValue, 0.0);
    });

    test('should handle negative values for pendingValue and totalValue', () {
      final negativeValueOrder = order.copyWith(
        pendingValue: -50.0,
        totalValue: -100.0,
      );

      expect(negativeValueOrder.pendingValue, -50.0);
      expect(negativeValueOrder.totalValue, -100.0);
    });

    test('should handle different user IDs', () {
      final differentUserOrder = order.copyWith(
        userId: 'user-999',
      );

      expect(differentUserOrder.userId, 'user-999');
    });
  });

  group('OrderStatus Tests', () {
    test('OrderStatus should have correct values', () {
      expect(OrderStatus.pending.index, 0);
      expect(OrderStatus.confirmed.index, 1);
    });

    test('OrderStatus should have correct string representation', () {
      expect(OrderStatus.pending.toString(), 'OrderStatus.pending');
      expect(OrderStatus.confirmed.toString(), 'OrderStatus.confirmed');
    });
  });
}