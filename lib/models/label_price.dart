class LabelPrice {
  final String? name;
  final int? userId;
  final int? status;
  final double price;

  LabelPrice({
    this.name, 
    this.userId, 
    this.status,
    required this.price
  });

  factory LabelPrice.fromJson(Map<String, dynamic> json) {
    return LabelPrice(
      name: json['name'],
      userId: json['user_id'],
      status: json['status'],
      price: double.parse(json['price'] ?? 0),
    );
  }

  @override
  String toString() {
    return 'LabelPrice(name: $name, userId: $userId, price: $price, status: $status)';
  }
}