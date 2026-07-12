import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:avianco/domain/models/reserva.dart';
import 'package:avianco/core/api.dart';
import 'package:avianco/services/auth_service.dart';

class ReservasProvider with ChangeNotifier {
  List<Reserva> _items = [];
  bool _isLoading = false;

  List<Reserva> get items => [..._items];
  bool get isLoading => _isLoading;

  Future<void> fetchReservas() async {
    _isLoading = true;
    notifyListeners();

    final token = await AuthService.getToken();
    final url = Uri.parse('${Api.baseUrl}/reservas/');

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
        _items = ListData.map((item) => Reserva.fromJson(item)).toList();
      }
    } catch (error) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReserva(Reserva reserva) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${Api.baseUrl}/reservas/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(reserva.toJson()),
      );

      if (response.statusCode == 201) {
        final newReserva = Reserva.fromJson(json.decode(response.body));
        _items.add(newReserva);
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }
}
