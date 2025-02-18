import 'dart:io';
import 'package:kekasir/models/product.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$apiUrl/products'), headers: await _headers);

    if (response.statusCode == 200) {
      List data = json.decode(response.body)['products'];
      return data.map((json) => Product.fromJson(json)).toList();
    }
    return [];
  }

  Future<bool> _sendProductRequest(String url, {String? name, String? price, String? shortDescription, File? imageFile}) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(await _headers);
    request.fields['name'] = name!;
    request.fields['price'] = price!;
    request.fields['short_description'] = shortDescription!;

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    var response = await request.send();
    return response.statusCode == 200;
  }

  Future<bool> createProduct(String name, String price, File? imageFile, String shortDescription) async {
    return _sendProductRequest('$apiUrl/product', name: name, price: price, shortDescription: shortDescription, imageFile: imageFile);
  }

  Future<bool> updateProduct(int id, String name, String price, File? imageFile, String shortDescription) async {
    return _sendProductRequest('$apiUrl/product/$id', name: name, price: price, shortDescription: shortDescription, imageFile: imageFile);
  }

  Future<bool> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/product/$id'), headers: await _headers);
    return response.statusCode == 200;
  }
}
