class CartSummary {
  final String totalPrice;
  final int totalQuantity;
  final List<CartItem> items;

  CartSummary({
    required this.totalPrice,
    required this.totalQuantity,
    required this.items,
  });

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    return CartSummary(
      totalPrice: json['total_price'] ?? "Rp 0",
      totalQuantity: json['total_quantity'] ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class CartItem {
  final int productId;
  final String productName;
  final int quantity;
  final String unitPrice;
  final String subtotal;

  CartItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? "",
      quantity: json['quantity'] ?? 0,
      unitPrice: json['unit_price'] ?? "Rp 0",
      subtotal: json['subtotal'] ?? "Rp 0",
    );
  }
}
