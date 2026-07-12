import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:avianco/domain/models/servicio.dart';
import 'package:avianco/core/api.dart';
import 'package:avianco/services/auth_service.dart';

class ServiciosProvider with ChangeNotifier {
  List<Servicio> _items = [];
  bool _isLoading = false;

  List<Servicio> get items => [..._items];
  bool get isLoading => _isLoading;

  Future<void> fetchServicios() async {
    _isLoading = true;
    notifyListeners();

    final token = await AuthService.getToken();
    final url = Uri.parse('${Api.baseUrl}/servicios/');

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
        final List<dynamic> listData = extractedData['results'] ?? [];
        _items = listData.map((item) => Servicio.fromJson(item)).toList();
      }
    } catch (error) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
