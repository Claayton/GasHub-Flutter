class ProductEntity {
  final String id;
  final String name;
  final double price;
  final String description;
  final int stockQuantity;

  ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.stockQuantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'stockQuantity': stockQuantity,
    };
  }

  factory ProductEntity.fromMap(Map<String, dynamic> map, {required String id}) {
    return ProductEntity(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      stockQuantity: (map['stockQuantity'] ?? 0).toInt(),
    );
  }

  factory ProductEntity.fromMapWithIdInData(Map<String, dynamic> map) {
    return ProductEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      stockQuantity: (map['stockQuantity'] ?? 0).toInt(),
    );
  }

  ProductEntity copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    int? stockQuantity,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }
}