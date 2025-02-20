import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ApiServiceTransaction {
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

  Future<void> saveTransaction(String paid, [int? paymentMethod, int? discount]) async {

    var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/transaction'));
    request.headers.addAll(await _headers);
    request.fields['paid'] = paid;
    request.fields['payment_method'] = paymentMethod.toString();
    request.fields['discount'] = discount.toString();

    var response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Gagal checkout');
    }
  }

}
