import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gashub_flutter/models/product_entity.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;


  ProductRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

    Future<String> addProduct(ProductEntity product) async {
      try {
        final docRef = await _firestore.collection('produtos').add(_toMap(product));
        return docRef.id;
      } catch (e) {
        throw Exception('Error creating product: $e');
      }
    }

    // Buscar produto por ID
  Future<ProductEntity?> getProduct(String id) async {
    try {
      final doc = await _firestore.collection('produtos').doc(id).get();
      if (doc.exists) {
        return _fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar produto: $e');
    }
  }

  // Buscar todos os produtos com opção de limite
  Future<List<ProductEntity>> getProducts({int limit = 20}) async {
    try {
      final query = _firestore.collection('produtos').limit(limit);
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => _fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar produtos: $e');
    }
  }

    // Atualizar produto
  Future<void> updateProduct(String id, ProductEntity product) async {
    try {
      await _firestore.collection('produtos').doc(id).update(_toMap(product));
    } catch (e) {
      throw Exception('Erro ao atualizar produto: $e');
    }
  }

  // Métodos de conversão
  Map<String, dynamic> _toMap(ProductEntity product) {
    return {
      'name': product.name,
      'price': product.price,
      'description': product.description,
      'stockQuantity': product.stockQuantity,
    };
  }

  ProductEntity _fromMap(Map<String, dynamic> map, String id) {
    return ProductEntity(
      id: id,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      description: map['description'] as String,
      stockQuantity: map['stockQuantity'] as int,
    );
  }
}