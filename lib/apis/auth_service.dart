import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/web.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String? apiUrl = dotenv.env['API_URL'];
  final String? bearerToken = dotenv.env['BEARER_TOKEN'];
  final String? apiToken = dotenv.env['API_TOKEN'];

  Future<Map<String, String>> get _headers async {
    String? token = await getToken();
    return {
      'Authorization': 'Bearer $token',
      'X-API-TOKEN': apiToken!,
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
  }
  
  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/login'),
      headers: {'X-API-TOKEN': apiToken!},
      body: {'email': email, 'password': password},
    );

    Logger().d(response.body); // Log respons dari server

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      return null; // Jika login berhasil, tidak ada error
    } else {
      final errorData = jsonDecode(response.body);
      return errorData['error']; // Mengembalikan pesan error dari API
    }
  }

  // Dapatkan Token dari SharedPreferences
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Logout dan Hapus Token
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  // Perbarui Token
  Future<bool> refreshToken() async {
    String? token = await getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$apiUrl/refresh-token'),
      headers: {'Authorization': 'Bearer $token','X-API-TOKEN': apiToken!},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newToken = data['access_token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', newToken);
      return true;
    } else {
      return false;
    }
  }

  // Ambil Data User dari API `/me`
  Future<Map<String, dynamic>?> fetchUser() async {
    String? token = await getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$apiUrl/me'),
      headers: {'Authorization': 'Bearer $token','X-API-TOKEN': apiToken!},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Simpan data user ke SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(data));

      return data;
    } else {
      throw Exception("Server sedang bermasalah");
    }
  }

  // Dapatkan Data User dari Local Storage
  Future<Map<String, dynamic>?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user');
    if (userData == null) return null;
    return jsonDecode(userData);
  }

  Future<Map<String, dynamic>> updateUser(String name, String address, String email, [String? oldPassword, String? password]) async {
    Map<String, dynamic> body = {
      'name': name,
      'email': email,
      'address' : address
    };

    if (password != null && password.isNotEmpty) {
      body['old_password'] = oldPassword ?? ''; 
      body['password'] = password;
    }

    final response = await http.put(
      Uri.parse('$apiUrl/user/update'),
      headers: await _headers,
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        "success": true,
        "message": data["message"] ?? "User berhasil diperbarui"
      };
    } else {
      return {
        "success": false,
        "message": data["message"] ?? "Gagal memperbarui user",
        "errors": data["errors"] ?? {} // Tambahkan errors jika ada
      };
    }
  }

  Future<String?> resetData(String password) async {

    var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/user/reset-data'));
    request.headers.addAll(await _headers);
    request.fields['password'] = password;

    var response = await request.send();
    var responseBody = await response.stream.bytesToString(); // Baca body dari Stream

    final jsonData = jsonDecode(responseBody);

    if (response.statusCode != 200) {
      return jsonData['message'] ?? "";
    }
    return null;
  }
}
