import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:kekasir/models/transaction.dart';
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

  Future<Map<String, dynamic>> saveTransaction(String paid, [int? paymentMethod, int? discount]) async {
    var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/transaction'));
    request.headers.addAll(await _headers);
    request.fields['paid'] = paid;
    request.fields['payment_method'] = paymentMethod?.toString() ?? '';
    request.fields['discount'] = discount?.toString() ?? '';

    var response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Gagal checkout');
    }

    // Konversi response ke JSON
    var responseData = await response.stream.bytesToString();
    return jsonDecode(responseData);
  }

  Future<Map<String, dynamic>?> getRevenue() async {
    final url = Uri.parse("$apiUrl/transaction/revenue");

    final response = await http.get(
      url,
      headers: await _headers
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Gagal mengambil data pendapatan");
    }
  }

  Future<List<Transaction>> fetchMutation(String startDate, String endDate) async {
    final response = await http.get(Uri.parse('$apiUrl/transaction/mutation?start_date=$startDate&end_date=$endDate'), headers: await _headers);

    if (response.statusCode == 200) {
      List data = json.decode(response.body)['data'];
      return data.map((json) => Transaction.fromJson(json)).toList();
    }
    return [];
  }
}
