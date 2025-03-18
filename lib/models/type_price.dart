class TypePrice {
  final String? name;
  final int? productId;
  final double? price;

  TypePrice({
    required this.name, 
    required this.productId, 
    required this.price,
  });

  factory TypePrice.fromJson(Map<String, dynamic> json) {
    return TypePrice(
      name: json['name'],
      productId: json['product_id'],
      price: double.parse(json['price'] ?? 0),
    );
  }

  @override
  String toString() {
    return 'name : $name, productId : $productId, price : $price';
  }
}
