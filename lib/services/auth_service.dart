import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avianco/core/api.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('Login error: $e');
      return {'error': 'connection_failure', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/auth/registro/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      print('Register error: $e');
      return {'error': 'connection_failure', 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/auth/registro/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    final body = jsonDecode(response.body);
    final Map<String, dynamic> result = body is Map<String, dynamic>
        ? Map<String, dynamic>.from(body)
        : {'detail': body.toString()};
    result['ok'] = response.statusCode == 200 || response.statusCode == 201;
    return result;
  }

  static Future<void> saveToken(
    String access,
    String refresh,
    bool isStaff, {
    int? userId,
    String? username,
    String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access', access);
    await prefs.setString('refresh', refresh);
    await prefs.setBool('is_staff', isStaff);
    if (userId != null) await prefs.setInt('user_id', userId);
    if (username != null) await prefs.setString('username', username);
    if (email != null) await prefs.setString('email', email);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
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
    final refresh = prefs.getString('refresh');
    final access = prefs.getString('access');

    if (refresh != null && access != null) {
      try {
        await http.post(
          Uri.parse('${Api.baseUrl}/auth/logout/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $access',
          },
          body: jsonEncode({'refresh': refresh}),
        );
      } catch (e) {
        print('Logout backend error: $e');
      }
    }
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
