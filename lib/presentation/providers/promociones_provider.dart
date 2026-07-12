import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:avianco/domain/models/promocion.dart';
import 'package:avianco/core/api.dart';
import 'package:avianco/services/auth_service.dart';

class PromocionesProvider with ChangeNotifier {
  List<Promocion> _items = [];
  bool _isLoading = false;

  List<Promocion> get items => [..._items];
  bool get isLoading => _isLoading;

  Future<void> fetchPromociones() async {
    _isLoading = true;
    notifyListeners();

    final token = await AuthService.getToken();
    final url = Uri.parse('${Api.baseUrl}/promociones/');

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
        _items = ListData.map((item) => Promocion.fromJson(item)).toList();
      }
    } catch (error) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
