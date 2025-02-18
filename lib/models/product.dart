class Product {
  final int id, availableStock;
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
    );
  }
}