import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:kekasir/models/stock.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ApiServiceStock {
  final String? apiUrl = dotenv.env['API_URL'];
  final String? apiToken = dotenv.env['API_TOKEN'];

  Future<Map<String, String>> get _headers async {
    String? token = await getToken();
    return {
      'Authorization': 'Bearer $token',
      'X-API-TOKEN': apiToken!,
    };
  }

  // Dapatkan Token dari SharedPreferences
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<StockData> fetchMutation(int productId) async {
    final response = await http.get(Uri.parse('$apiUrl/detail-stock/$productId'), headers: await _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];

      Logger().d(data);

      return StockData.fromJson(data);
    }
    
    return StockData(stockList: [], totalStockIn: 0, totalStockOut: 0);
  }

}
