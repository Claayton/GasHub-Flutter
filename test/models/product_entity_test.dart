import 'package:flutter_test/flutter_test.dart';
import 'package:gashub_flutter/models/product_entity.dart';

void main() {
  // Configuração do teste
  final product = ProductEntity(
    id: '1',
    name: 'Gás 13kg',
    price: 89.90,
    description: 'Botijão P13',
    stockQuantity: 50,
  );

  // Teste 1: Valores corretos
  test('should have correct values', () {
    expect(product.id, '1');
    expect(product.name, 'Gás 13kg');
    expect(product.price, 89.90);
    expect(product.description, 'Botijão P13');
    expect(product.stockQuantity, 50);
  });

  // Teste 2: Cópia com alteração
  test('copyWith should update only provided fields', () {
    final updatedProduct = product.copyWith(price: 99.90);
    
    expect(updatedProduct.id, '1');
    expect(updatedProduct.name, 'Gás 13kg');
    expect(updatedProduct.price, 99.90); // SÓ ESSE MUDOU!
    expect(updatedProduct.description, 'Botijão P13');
    expect(updatedProduct.stockQuantity, 50);
  });
}