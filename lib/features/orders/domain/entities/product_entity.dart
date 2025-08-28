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
