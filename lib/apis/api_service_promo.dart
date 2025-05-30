import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:kekasir/models/cart_summary.dart';
import 'package:logger/web.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ApiServicePromo {
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

  Future<bool> updatePromo(int productId, String percentage, String nominalDiscount, bool isPercentage) async {

    var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/promo/$productId'));
    request.headers.addAll(await _headers);
    request.fields['percentage'] = percentage.toString();
    request.fields['nominal_discount'] = nominalDiscount.toString();
    request.fields['isPercentage'] = isPercentage.toString();

    var response = await request.send();
    return response.statusCode == 200;
  }
  
  Future<CartSummary> fetchCartSummary() async {
    final response = await http.get(Uri.parse('$apiUrl/cart/total-price'), headers: await _headers);

    if (response.statusCode == 200) {
      Logger().d(response.body);
      final Map<String, dynamic> data = json.decode(response.body);
      return CartSummary.fromJson(data);
    } else {
      return CartSummary(totalPrice: "Rp 0", totalQuantity: 0, items: [], subTotal: '', totalDiscount: '');
    }
  }
}
