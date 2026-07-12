import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avianco/core/api.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_token != null) {
      return _token;
    }
    return null;
  }

  Future<void> login(String username, String password) async {
    final url = Uri.parse('${Api.baseUrl}/auth/login/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode != 200) {
        throw Exception(responseData['detail'] ?? 'Error al iniciar sesión');
      }

      _token = responseData['access'];
      _userId = responseData['user_id']?.toString();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      if (_userId != null) await prefs.setString('userId', _userId!);

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) {
      return;
    }
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    notifyListeners();
  }
}
