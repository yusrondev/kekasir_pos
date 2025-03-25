class LabelPrice {
  final int? id;
  final String? name;
  final int? userId;
  final int? status;
  final double price;

  LabelPrice({
    this.id, 
    this.name, 
    this.userId, 
    this.status,
    required this.price
  });

  factory LabelPrice.fromJson(Map<String, dynamic> json) {
    return LabelPrice(
      id: json['id'],
      name: json['name'],
      userId: json['user_id'],
      status: json['status'],
      price: double.parse(json['price'] ?? 0),
    );
  }

  @override
  String toString() {
    return 'LabelPrice(id: $id, name: $name, userId: $userId, price: $price, status: $status)';
  }
}