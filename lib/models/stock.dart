class Stock {
  final int? transactionId;
  final int id, productId, userId, quantity;
  final String? description, type, createdAt;
  final double costPrice;

  Stock({
    required this.id, 
    required this.productId, 
    required this.userId, 
    required this.quantity, 
    required this.costPrice,
    this.description, 
    this.transactionId,
    this.createdAt, 
    required this.type
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'],
      productId : json['product_id'],
      userId : json['user_id'],
      transactionId : json['transaction_id'],
      quantity : json['quantity'],
      costPrice: (json['cost_price'] != null) 
    ? double.tryParse(json['cost_price'].toString()) ?? 0.0
    : 0.0,
      description : json['description'] ?? "",
      type : json['type'],
      createdAt : json['created_at'],
    );
  }

  @override
  String toString() {
    return 'id : $id, productId : $productId, userId : $userId, quantity : $quantity, cost_price : $costPrice, description : $description, type : $type, created_at : $createdAt';
  }
}

class StockData {
  final List<Stock> stockList;
  final int totalStockIn;
  final int totalStockOut;

  StockData({
    required this.stockList,
    required this.totalStockIn,
    required this.totalStockOut,
  });

  factory StockData.fromJson(Map<String, dynamic> json) {
    return StockData(
      stockList: (json['stock'] as List).map((data) => Stock.fromJson(data)).toList(),
      totalStockIn: json['total_stock']['in'],
      totalStockOut: json['total_stock']['out'],
    );
  }

  @override
  String toString() {
    return 'Total Stock In: $totalStockIn, Total Stock Out: $totalStockOut, Stock List: $stockList';
  }
}
