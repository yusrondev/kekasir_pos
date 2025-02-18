import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String? apiUrl = dotenv.env['API_URL'];
  final String? bearerToken = dotenv.env['BEARER_TOKEN'];
  final String? apiToken = dotenv.env['API_TOKEN'];
  
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/login'),
      headers: {'X-API-TOKEN': apiToken!},
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      return true;
    } else {
      return false;
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
      return null;
    }
  }

  // Dapatkan Data User dari Local Storage
  Future<Map<String, dynamic>?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user');
    if (userData == null) return null;
    return jsonDecode(userData);
  }
}
