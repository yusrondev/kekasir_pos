class CartSummary {
  final String totalPrice;
  final String subTotal;
  final String totalDiscount;
  final int totalQuantity;
  final List<CartItem> items;

  CartSummary({
    required this.totalPrice,
    required this.subTotal,
    required this.totalDiscount,
    required this.totalQuantity,
    required this.items,
  });

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    return CartSummary(
      totalPrice: json['total_price'] ?? "Rp 0",
      subTotal: json['sub_total'] ?? "Rp 0",
      totalDiscount: json['total_discount'] ?? "Rp 0",
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
  final String productShortDescription;
  final String productImage;
  final int quantity;
  final String unitPrice;
  final String subtotal;

  CartItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.productShortDescription,
    required this.productImage,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? "",
      productShortDescription: json['product_description'] ?? "",
      productImage: json['product_image'] ?? "",
      quantity: json['quantity'] ?? 0,
      unitPrice: json['unit_price'] ?? "Rp 0",
      subtotal: json['subtotal'] ?? "Rp 0",
    );
  }
}
