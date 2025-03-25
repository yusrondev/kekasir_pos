class LabelPrice {
  final int? id;
  final String? name;
  final int? userId;
  final int? status;
  final int? productId;
  final double price;

  LabelPrice({
    this.id, 
    this.name, 
    this.userId, 
    this.status,
    this.productId,
    required this.price
  });

  factory LabelPrice.fromJson(Map<String, dynamic> json) {
    return LabelPrice(
      id: json['id'],
      name: json['name'],
      userId: json['user_id'],
      status: json['status'],
      productId: json['product_id'],
      price: double.parse(json['price'] ?? 0),
    );
  }

  @override
  String toString() {
    return 'LabelPrice(id: $id, name: $name, userId: $userId, price: $price, product_id : $productId, status: $status)';
  }
}