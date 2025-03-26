class Transaction {
  final int id;
  final String code;
  final String description;
  final String? labelPrice;
  final String subTotal;
  final String grandTotal;
  final String discount;
  final String paid;
  final String change;
  final String paymentMethod;
  final int status;
  final String merchantName;
  final String createdAt;
  final List<TransactionDetail> details;

  Transaction({
    required this.id,
    required this.code,
    required this.description,
    required this.labelPrice,
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
      labelPrice: json['label_price'],
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

  @override
  String toString() {
    return 'id : $id, code : $code, description : $description, labelPrice : $labelPrice, subTotal : $subTotal, grandTotal : $grandTotal, discount : $discount, paid : $paid, change : $change, paymentMethod : $paymentMethod, status : $status, merchantName : $merchantName, createdAt : $createdAt, details : $details';
  }
}

class TransactionData {
  final List<Transaction> transactionList;
  final String grandTotal;

  TransactionData({
    required this.transactionList,
    required this.grandTotal
  });

  factory TransactionData.fromJson(Map<String, dynamic> json){
    return TransactionData(
      transactionList: (json['transaction'] as List).map((data) => Transaction.fromJson(data)).toList(),
      grandTotal: json['grand_total']
    );
  }

  @override
  String toString() {
    return 'Transaction: $transactionList, Grand Total: $grandTotal';
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
