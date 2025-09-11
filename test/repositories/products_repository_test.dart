import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:gashub_flutter/models/product_entity.dart';
import 'package:gashub_flutter/repositories/product_repository.dart';

// Factory function para criar produto fake
ProductEntity buildFakeProduct({String? id}) {
  return ProductEntity(
    id: id ?? '',
    name: 'Produto Teste',
    price: 29.90,
    description: 'Descrição do produto teste',
    stockQuantity: 15,
  );
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ProductRepository productRepository;

  // Setup inicial antes de cada teste
  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    productRepository = ProductRepository(firestore: fakeFirestore);
  });

  group('ProductRepository setup', () {
    test('Deve inicializar o repositório com FakeFirebaseFirestore', () {
      expect(productRepository, isA<ProductRepository>());
    });
  });

  group('addProduct', () {
    test('Deve criar um produto e retornar o ID do documento', () async {
      // Arrange
      final product = buildFakeProduct();

      // Act
      final productId = await productRepository.addProduct(product);

      // Assert
      expect(productId, isNotEmpty);

      // Verifica se realmente foi salvo no Firestore
      final doc = await fakeFirestore.collection('produtos').doc(productId).get();
      expect(doc.exists, true);
      expect(doc.data()?['name'], equals(product.name));
      expect(doc.data()?['price'], equals(product.price));
    });
  });

  group('getProduct', () {
    test('Deve retornar um produto existente pelo ID', () async {
      // Arrange
      final product = buildFakeProduct();
      final productId = await productRepository.addProduct(product);

      // Act
      final fetchedProduct = await productRepository.getProduct(productId);

      // Assert
      expect(fetchedProduct, isNotNull);
      expect(fetchedProduct?.id, equals(productId));
      expect(fetchedProduct?.name, equals(product.name));
      expect(fetchedProduct?.price, equals(product.price));
    });

    test('Deve retornar null se o produto não existir', () async {
      // Act
      final fetchedProduct = await productRepository.getProduct('id_inexistente');

      // Assert
      expect(fetchedProduct, isNull);
    });
  });

  group('getProducts', () {
    test('Deve retornar lista de produtos', () async {
      // Arrange
      final product1 = buildFakeProduct();
      final product2 = product1.copyWith(
        name: 'Novo Nome',
      );
      
      await productRepository.addProduct(product1);
      await productRepository.addProduct(product2);

      // Act
      final products = await productRepository.getProducts();

      // Assert
      expect(products.length, 2);
      expect(products[0].name, equals(product1.name));
      expect(products[1].name, equals(product2.name));
    });

    test('Deve respeitar o limite de produtos', () async {
      // Arrange - adiciona 5 produtos
      for (int i = 0; i < 5; i++) {
        await productRepository.addProduct(buildFakeProduct());
      }

      // Act - busca apenas 3
      final products = await productRepository.getProducts(limit: 3);

      // Assert
      expect(products.length, 3);
    });

    test('Deve retornar lista vazia se não houver produtos', () async {
      // Act
      final products = await productRepository.getProducts();

      // Assert
      expect(products, isEmpty);
    });
  });

  group('updateProduct', () {
    test('Deve atualizar os dados de um produto existente', () async {
      // Arrange
      final product = buildFakeProduct();
      final productId = await productRepository.addProduct(product);

      final updatedProduct = ProductEntity(
        id: productId,
        name: 'Nome Atualizado',
        price: 39.90,
        description: 'Descrição atualizada',
        stockQuantity: 20,
      );

      // Act
      await productRepository.updateProduct(productId, updatedProduct);

      // Assert
      final fetchedProduct = await productRepository.getProduct(productId);
      expect(fetchedProduct?.name, equals('Nome Atualizado'));
      expect(fetchedProduct?.price, equals(39.90));
      expect(fetchedProduct?.stockQuantity, equals(20));
    });

    test('Deve lançar exceção ao tentar atualizar produto inexistente', () async {
      // Arrange
      final product = buildFakeProduct(id: 'id_inexistente');

      // Act & Assert
      expect(() async => await productRepository.updateProduct('id_inexistente', product),
          throwsA(isA<Exception>()));
    });
  });
}