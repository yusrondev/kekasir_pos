class Stock {
  final int id, productId, userId, quantity;
  final String? description, type, createdAt;

  Stock({
    required this.id, 
    required this.productId, 
    required this.userId, 
    required this.quantity, 
    this.description, 
    this.createdAt, 
    required this.type
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'],
      productId : json['product_id'],
      userId : json['user_id'],
      quantity : json['quantity'],
      description : json['description'] ?? "",
      type : json['type'],
      createdAt : json['created_at'],
    );
  }

  @override
  String toString() {
    return 'id : $id, productId : $productId, userId : $userId, quantity : $quantity, description : $description, type : $type, created_at : $createdAt';
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
