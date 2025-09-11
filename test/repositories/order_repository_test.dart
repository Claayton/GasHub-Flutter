import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:gashub_flutter/models/order_entity.dart';
import 'package:gashub_flutter/models/product_entity.dart';
import 'package:gashub_flutter/repositories/order_repository.dart';

OrderEntity buildFakeOrder() {
  return OrderEntity(
    id: 'order1',
    customerName: 'Cliente Teste',
    customerAddress: 'Rua Teste, 123',
    products: [
      ProductEntity(
        id: 'p1',
        name: 'Produto 1',
        price: 10.0,
        description: 'Descrição produto 1',
        stockQuantity: 5,
      ),
    ],
    orderDateTime: DateTime.now(),
    paymentMethod: PaymentMethods.dinheiro,
    dueDate: DateTime.now().add(Duration(days: 2)),
    status: OrderStatus.pending,
    pendingValue: 10.0,
    totalValue: 10.0,
    userId: 'user1',
  );
}


void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late OrderRepository orderRepository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    orderRepository = OrderRepository(firestore: fakeFirestore);
  });

  group('OrderRepository setup', () {
    test('Deve inicializar o repositório com FakeFirebaseFirestore', () {
      expect(orderRepository, isA<OrderRepository>());
    });
  });

  group('createOrder', () {
    test('Deve criar um pedido e retornar o ID do documento', () async {
      // Arrange
      final order = buildFakeOrder();

      // Act
      final orderId = await orderRepository.createOrder(order);

      // Assert
      expect(orderId, isNotEmpty);

      // Verifica se realmente foi salvo no Firestore
      final doc = await fakeFirestore.collection('pedidos').doc(orderId).get();
      expect(doc.exists, true);
      expect(doc.data()?['customerName'], equals(order.customerName));
    });
  });

  group('getOrder', () {
    test('Deve retornar um pedido existente pelo ID', () async {
      // Arrange
      final order = buildFakeOrder();
      final id = await orderRepository.createOrder(order);

      // Act
      final fetchedOrder = await orderRepository.getOrder(id);

      // Assert
      expect(fetchedOrder, isNotNull);
      expect(fetchedOrder?.id, equals(id));
      expect(fetchedOrder?.customerName, equals(order.customerName));
    });

    test('Deve retornar null se o pedido não existir', () async {
      // Act
      final fetchedOrder = await orderRepository.getOrder('id_inexistente');

      // Assert
      expect(fetchedOrder, isNull);
    });
  });

  group('watchOrders', () {
    test('Deve emitir lista de pedidos em tempo real em ordem decrescente', () async {
      // Arrange
      final order1 = buildFakeOrder();
      final order2 = buildFakeOrder().copyWith(
        id: 'order2',
        orderDateTime: DateTime.now().add(Duration(minutes: 5)), // mais novo
        customerAddress: 'Rua dos bobos numero zero'
      );

      await orderRepository.createOrder(order1);
      await orderRepository.createOrder(order2);

      // Act
      final stream = orderRepository.watchOrders();

      // Assert
      final orders = await stream.first;
      expect(orders.length, 2);
      expect(orders.first.customerAddress, 'Rua dos bobos numero zero');
      expect(orders.last.customerAddress, 'Rua Teste, 123');
    });
  });

  group('updateOrder', () {
    test('Deve atualizar os dados de um pedido existente', () async {
      // Arrange
      final order = buildFakeOrder();
      final id = await orderRepository.createOrder(order);

      final updatedOrder = order.copyWith(
        customerName: 'Novo Nome',
        totalValue: 50.0,
      );

      // Act
      await orderRepository.updateOrder(id, updatedOrder);

      // Assert
      final fetchedOrder = await orderRepository.getOrder(id);
      expect(fetchedOrder?.customerName, equals('Novo Nome'));
      expect(fetchedOrder?.totalValue, equals(50.0));
    });
  });




}

