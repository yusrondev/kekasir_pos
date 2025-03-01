class Transaction {
  final int id;
  final String code;
  final String description;
  final String subTotal;
  final String grandTotal;
  final String discount;
  final String paid;
  final String change;
  final int paymentMethod;
  final int status;
  final String merchantName;
  final String createdAt;
  final List<TransactionDetail> details;

  Transaction({
    required this.id,
    required this.code,
    required this.description,
    required this.subTotal,
    required this.grandTotal,
    required this.discount,
    required this.paid,
    required this.change,
    required this.paymentMethod,
    required this.status,
    required this.merchantName,
    required this.createdAt,
    required this.details,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      code: json['code'],
      description: json['description'],
      subTotal: json['sub_total'],
      grandTotal: json['grand_total'],
      discount: json['discount'],
      paid: json['paid'],
      change: json['change'],
      paymentMethod: json['payment_method'],
      status: json['status'],
      merchantName: json['merchant_name'],
      createdAt: json['created_at'],
      details: (json['details'] as List)
          .map((item) => TransactionDetail.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "code": code,
      "merchant_name": merchantName,
      "created_at": createdAt,
      "details": details,
      "sub_total": subTotal,
      "grand_total": grandTotal,
      "discount": discount,
      "paid": paid,
      "change": change,
    };
  }
}

class TransactionDetail {
  final int id;
  final int quantity;
  final int price;
  final String subTotal;
  final Product product;

  TransactionDetail({
    required this.id,
    required this.quantity,
    required this.price,
    required this.subTotal,
    required this.product,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      id: json['id'],
      quantity: json['quantity'],
      price: json['price'],
      subTotal: json['sub_total'],
      product: Product.fromJson(json['product']),
    );
  }
}

class Product {
  final int id;
  final String name;
  final String price;

  Product({required this.id, required this.name, required this.price});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
    );
  }
}
