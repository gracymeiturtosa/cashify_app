class Product {
  final int id;
  final String name;
  final double price;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ?? 'Unknown',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      stock: map['stock'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'price': price, 'stock': stock};
  }

  Product copyWith({int? id, String? name, double? price, int? stock}) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, stock: $stock)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.price == price &&
        other.stock == stock;
  }

  @override
  int get hashCode => Object.hash(id, name, price, stock);
}
