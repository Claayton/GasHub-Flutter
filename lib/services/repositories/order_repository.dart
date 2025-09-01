import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gasbub_flutter/models/entities/product_entity.dart';
import 'package:gasbub_flutter/models/entities/order_entity.dart';

class OrderRepository {
  final FirebaseFirestore _firestore;


  OrderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

    Future<String> createOrder(OrderEntity order) async {
      try {
        final docRef = await _firestore.collection('pedidos').add(_toMap(order));
        return docRef.id;
      } catch (e) {
        throw Exception('Error creating order: $e');
      }
    }
    
    // Buscar pedido por ID
  Future<OrderEntity?> getOrder(String id) async {
    try {
      final doc = await _firestore.collection('pedidos').doc(id).get();
      if (doc.exists) {
        return _fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar pedido: $e');
    }
  }

  // Listener em tempo real para todos os pedidos
  Stream<List<OrderEntity>> watchOrders() {
    return _firestore
        .collection('pedidos')
        .orderBy('orderDateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _fromMap(doc.data(), doc.id))
            .toList());
  }


    // Atualizar pedido
  Future<void> updateOrder(String id, OrderEntity order) async {
    try {
      await _firestore.collection('pedidos').doc(id).update(_toMap(order));
    } catch (e) {
      throw Exception('Erro ao atualizar pedido: $e');
    }
  }

  // Métodos de conversão
  Map<String, dynamic> _toMap(OrderEntity order) {
    return {
      'customerName': order.customerName,
      'customerAddress': order.customerAddress,
      'products': order.products.map((product) => _productToMap(product)).toList(),
      'orderDateTime': Timestamp.fromDate(order.orderDateTime),
      'paymentMethod': _paymentMethodToString(order.paymentMethod),
      'dueDate': Timestamp.fromDate(order.dueDate),
      'status': _statusToString(order.status),
      'pendingValue': order.pendingValue,
      'totalValue': order.totalValue,
      'userId': order.userId,
    };
  }

  OrderEntity _fromMap(Map<String, dynamic> map, String id) {
    return OrderEntity(
      id: id,
      customerName: map['customerName'] as String,
      customerAddress: map['customerAddress'] as String,
      products: List<ProductEntity>.from(
        (map['products'] as List).map((productMap) =>
          _productFromMap(productMap as Map<String, dynamic>)
        ),
      ),
      orderDateTime: (map['orderDateTime'] as Timestamp).toDate(),
      paymentMethod: _paymentMethodFromString(map['paymentMethod']),
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      status: _statusFromString(map['status']),
      pendingValue: (map['pendingValue'] as num).toDouble(),
      totalValue: (map['totalValue'] as num).toDouble(),
      userId: map['userId'],
    );
  }

  // Métodos auxiliares para ProductEntity (você pode mover para ProductRepository depois)
  Map<String, dynamic> _productToMap(ProductEntity product) {
    return {
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'description': product.description,
      'stockQuantity': product.stockQuantity,
    };
  }

  ProductEntity _productFromMap(Map<String, dynamic> map) {
    return ProductEntity(
      id: map['id'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      description: map['description'],
      stockQuantity: map['stockQuantity'],
    );
  }

  // Conversores de status
  String _statusToString(OrderStatus status) {
    return status.toString().split('.').last;
  }

  OrderStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      default:
        return OrderStatus.pending;
    }
  }
}

// Conversores de paymentMethod
String _paymentMethodToString(PaymentMethods method) {
  return method.toString().split('.').last;
}

PaymentMethods _paymentMethodFromString(String method) {
  switch (method) {
    case 'dinheiro':
      return PaymentMethods.dinheiro;
    case 'pix':
      return PaymentMethods.pix;
    case 'credito':
      return PaymentMethods.credito;
    case 'debito':
    return PaymentMethods.debito;
    default:
      return PaymentMethods.dinheiro; // fallback
  }
}
