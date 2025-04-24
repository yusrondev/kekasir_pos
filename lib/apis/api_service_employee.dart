import 'package:kekasir/models/employee.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/web.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ApiServiceEmployee {
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

  Future<List<Employee>> fetchEmployee() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/employee'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body)['employee'];
        return data.map((json) => Employee.fromJson(json)).toList();
      } else {
        if (response.statusCode == 403) {
          throw Exception("expired");
        }
        Logger().d('Gagal mengambil Pegawai. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('expired')) {
        throw Exception("expired");
      }
    }

    return [];
  }

  Future<String?> register(String name,String? address, String email, String password) async {
    Logger().d('ping');

    final response = await http.post(
      Uri.parse('$apiUrl/employee/store'),
      headers: await _headers,
      body: {
        'name': name,
        'address': address,
        'email': email, 
        'password': password
      },
    );

    Logger().d(response.statusCode); // Log respons dari server

    if (response.statusCode == 200) {
      return null; // Jika login berhasil, tidak ada error
    } else {
      final errorData = jsonDecode(response.body);
      return errorData['error']; // Mengembalikan pesan error dari API
    }
  }

  Future<String?> update(String? id, String name,String? address, String email, String password) async {
    Logger().d('ping');

    final response = await http.post(
      Uri.parse('$apiUrl/employee/update/$id'),
      headers: await _headers,
      body: {
        'name': name,
        'address': address,
        'email': email, 
        'password': password
      },
    );

    Logger().d(response.statusCode); // Log respons dari server

    if (response.statusCode == 200) {
      return null; // Jika login berhasil, tidak ada error
    } else {
      final errorData = jsonDecode(response.body);
      return errorData['error']; // Mengembalikan pesan error dari API
    }
  }

  Future<bool> delete(String id) async {
    final response = await http.delete(Uri.parse('$apiUrl/employee/delete/$id'), headers: await _headers);
    return response.statusCode == 200;
  }
}
