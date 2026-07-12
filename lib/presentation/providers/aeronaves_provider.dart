import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:avianco/domain/models/aeronave.dart';
import 'package:avianco/core/api.dart';
import 'package:avianco/services/auth_service.dart';

class AeronavesProvider with ChangeNotifier {
  List<Aeronave> _items = [];
  bool _isLoading = false;

  List<Aeronave> get items => [..._items];
  bool get isLoading => _isLoading;

  Future<void> fetchAeronaves({String search = ''}) async {
    _isLoading = true;
    notifyListeners();

    final token = await AuthService.getToken();
    final url = Uri.parse('${Api.baseUrl}/aeronaves/?search=$search');

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
        final List<dynamic> aeronavesList = extractedData['results'] ?? [];
        _items = aeronavesList.map((item) => Aeronave.fromJson(item)).toList();
      }
    } catch (error) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAeronave(Aeronave aeronave) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${Api.baseUrl}/aeronaves/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(aeronave.toJson()),
      );

      if (response.statusCode == 201) {
        final newAeronave = Aeronave.fromJson(json.decode(response.body));
        _items.add(newAeronave);
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }
}
