import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kekasir/models/label_price.dart';
import 'package:kekasir/models/type_price.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/web.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiServiceTypePrice {
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

  Future<List<TypePrice>> fetchTypePrice(String keyword, [String? sort]) async {
    final response = await http.get(Uri.parse('$apiUrl/type-prices'), headers: await _headers);

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => TypePrice.fromJson(json)).toList();
    }
    return [];
  }

  Future<String?> _sendLabelRequest(String url, {String? name, String? productId}) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(await _headers);
    
    if (name != null) {
      request.fields['name'] = name;
      request.fields['product_id'] = productId.toString();
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString(); // Baca body dari Stream

    final jsonData = jsonDecode(responseBody);

    Logger().d(response.statusCode);

    if (response.statusCode != 201) {
      return jsonData['message'] ?? "";
    }
    return null;
  }

  Future<String?> _sendTypePriceRequest(String url, {String? price, String? name, int? productId}) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(await _headers);
    
    if (price != null) {
      request.fields['name'] = name.toString();
      request.fields['price'] = price;
      request.fields['product_id'] = productId.toString();
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString(); // Baca body dari Stream

    final jsonData = jsonDecode(responseBody);

    Logger().d(response.statusCode);

    if (response.statusCode != 200) {
      return jsonData['message'] ?? "";
    }
    return null;
  }

  Future<String?> updateLabelPrice(String name, String? productId) async {
    return _sendLabelRequest('$apiUrl/label-price', name: name, productId: productId);
  }

  Future<String?> updateTypePrice(String price, String? name, int productId) async {
    return _sendTypePriceRequest('$apiUrl/type-price/$productId', price: price, name : name, productId: productId);
  }

  Future<List<LabelPrice>> fetchLabelPrice(int productId) async {
    try {
      final response = await http
          .get(Uri.parse('$apiUrl/label-prices/$productId'), headers: await _headers)
          .timeout(const Duration(seconds: 10)); // Tambah timeout

      if (response.statusCode == 200) {
        List data = json.decode(response.body)['labels'];
        return data.map((json) => LabelPrice.fromJson(json)).toList();
      } else {
        Logger().d('Error: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException {
      Logger().d('Request timeout, coba lagi nanti.');
    } on SocketException {
      Logger().d('Tidak dapat terhubung ke server, periksa koneksi internet.');
    } catch (e) {
      Logger().d('Terjadi kesalahan: $e');
    }

    return [];
  }

}