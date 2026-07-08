import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<void> saveToken(
    String access,
    String refresh,
    bool isStaff,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access', access);
    await prefs.setString('refresh', refresh);
    await prefs.setBool('is_staff', isStaff);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access');
  }

  static Future<bool> isStaff() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_staff') ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
