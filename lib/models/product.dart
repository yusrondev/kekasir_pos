class Product {
  final int id, availableStock, quantity;
  final String code, name, shortDescription, image;
  final double price;

  Product({
    required this.id,
    required this.code,
    required this.name,
    required this.shortDescription,
    required this.image,
    required this.price,
    required this.availableStock,
    this.quantity = 0, // Default 0
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      shortDescription: json['short_description'],
      image: json['image'],
      price: double.parse(json['price']),
      availableStock: json['available_stock'],
      quantity: json['quantity'] ?? 0,
    );
  }

  Product copyWith({int? quantity}) {
    return Product(
      id: id,
      code: code,
      name: name,
      shortDescription: shortDescription,
      image: image,
      price: price,
      availableStock: availableStock,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() {
    return 'id: $id, code: $code, name: $name, price: $price, image: $image, quantity: $quantity';
  }
}
