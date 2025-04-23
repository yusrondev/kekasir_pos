class Product {
  final int id, availableStock, quantity;
  final String code, name, shortDescription, image;
  final double price, nominalDiscount, finalPrice, calculatedPrice, realPrice;
  final bool haveType, isDiscount;

  Product({
    required this.id,
    required this.code,
    required this.name,
    required this.shortDescription,
    required this.image,
    required this.price,
    required this.availableStock,
    this.quantity = 0, // Default 0,
    required this.nominalDiscount,
    required this.finalPrice,
    this.haveType = false,
    this.isDiscount = false,
    required this.calculatedPrice,
    required this.realPrice,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      code: json['code'],
      name: json['name'] ?? "",
      shortDescription: json['short_description'] ?? "",
      image: json['image'] ?? "",
      haveType: json['have_type'],
      isDiscount: json['is_discount'],
      price: double.parse(json['price'] ?? 0),
      availableStock: json['available_stock'] ?? 0,
      quantity: json['quantity'] ?? 0,
      nominalDiscount: double.parse(json['nominal_discount'] ?? 0),
      finalPrice: double.parse(json['final_price'] ?? 0),
      calculatedPrice: double.parse(json['calculated_price'] ?? 0),
      realPrice: double.parse(json['real_price'] ?? 0),
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
      haveType: haveType,
      isDiscount: isDiscount,
      availableStock: availableStock,
      quantity: quantity ?? this.quantity,
      nominalDiscount: nominalDiscount,
      finalPrice: finalPrice,
      calculatedPrice: calculatedPrice,
      realPrice: realPrice,
    );
  }

  @override
  String toString() {
    return 'id: $id, code: $code, name: $name, price: $price, image: $image, quantity: $quantity, haveType: $haveType, calculatedPrice : $calculatedPrice, nominalDiscount : $nominalDiscount, realPrice : $realPrice, isDiscount : $isDiscount';
  }
}
