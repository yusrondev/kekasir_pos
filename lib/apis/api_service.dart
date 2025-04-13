import 'dart:io';
import 'package:kekasir/models/product.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/web.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
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

  Future<List<Product>> fetchProducts(String keyword, [String? sort, String? typePrice]) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/products?keyword=$keyword&sort_qty=$sort&type_price=$typePrice'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body)['products'];
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        // Log kesalahan jika response gagal
        Logger().d('Gagal mengambil produk. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Menangani error jaringan atau parsing JSON
      Logger().d('Terjadi kesalahan: $e');
    }

    // Jika terjadi error, kembalikan list kosong agar aplikasi tetap berjalan
    return [];
  }


  Future<bool> _sendProductRequest(String url, {String? code, String? name, String? price, String? shortDescription, File? imageFile, String? type, String? quantity, String? costPrice, String? description}) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(await _headers);
    request.fields['code'] = code!;
    request.fields['name'] = name!;
    request.fields['price'] = price!;
    request.fields['short_description'] = shortDescription!;
    request.fields['type'] = type!;
    request.fields['quantity'] = quantity!;
    request.fields['cost_price'] = costPrice!;
    request.fields['description'] = description!;

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    var response = await request.send();
    return response.statusCode == 200;
  }

  Future<bool> createProduct(String code, String name, String price, File? imageFile, String shortDescription, String? type, String? quantity, String? costPrice, String? description) async {
    return _sendProductRequest('$apiUrl/product',code : code, name: name, price: price, shortDescription: shortDescription, imageFile: imageFile, type: type, quantity: quantity, costPrice: costPrice, description : description);
  }

  Future<bool> updateProduct(int id, String code, String name, String price, File? imageFile, String shortDescription, String? type, String? quantity, String? costPrice, String? description) async {
    return _sendProductRequest('$apiUrl/product/$id',code : code, name: name, price: price, shortDescription: shortDescription, imageFile: imageFile, type: type, quantity: quantity, costPrice: costPrice , description : description);
  }

  Future<bool> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/product/$id'), headers: await _headers);
    return response.statusCode == 200;
  }
}
