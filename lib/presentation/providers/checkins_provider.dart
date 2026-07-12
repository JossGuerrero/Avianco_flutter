import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:avianco/domain/models/checkin.dart';
import 'package:avianco/core/api.dart';
import 'package:avianco/services/auth_service.dart';

class CheckinsProvider with ChangeNotifier {
  List<Checkin> _items = [];
  bool _isLoading = false;

  List<Checkin> get items => [..._items];
  bool get isLoading => _isLoading;

  Future<void> fetchCheckins() async {
    _isLoading = true;
    notifyListeners();

    final token = await AuthService.getToken();
    final url = Uri.parse('${Api.baseUrl}/checkins/');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body);
        final List<dynamic> ListData = extractedData['results'] ?? [];
        _items = ListData.map((item) => Checkin.fromJson(item)).toList();
      }
    } catch (error) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
