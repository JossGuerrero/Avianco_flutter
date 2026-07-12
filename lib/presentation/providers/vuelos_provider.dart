import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:avianco/domain/models/vuelo.dart';
import 'package:avianco/core/api.dart';
import 'package:avianco/services/auth_service.dart';

class VuelosProvider with ChangeNotifier {
  List<Vuelo> _items = [];
  bool _isLoading = false;

  List<Vuelo> get items => [..._items];
  bool get isLoading => _isLoading;

  Future<void> fetchVuelos({String search = ''}) async {
    _isLoading = true;
    notifyListeners();

    final token = await AuthService.getToken();
    final url = Uri.parse('${Api.baseUrl}/vuelos/?search=$search');

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
        final List<dynamic> vuelosList = extractedData['results'] ?? [];
        _items = vuelosList.map((item) => Vuelo.fromJson(item)).toList();
      }
    } catch (error) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addVuelo(Vuelo vuelo) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${Api.baseUrl}/vuelos/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(vuelo.toJson()),
      );

      if (response.statusCode == 201) {
        final newVuelo = Vuelo.fromJson(json.decode(response.body));
        _items.add(newVuelo);
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateVuelo(int id, Vuelo newVuelo) async {
    final flightIndex = _items.indexWhere((v) => v.id == id);
    if (flightIndex >= 0) {
      final token = await AuthService.getToken();
      final url = Uri.parse('${Api.baseUrl}/vuelos/$id/');
      await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(newVuelo.toJson()),
      );
      _items[flightIndex] = newVuelo;
      notifyListeners();
    }
  }

  Future<void> deleteVuelo(int id) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${Api.baseUrl}/vuelos/$id/');
    final existingFlightIndex = _items.indexWhere((v) => v.id == id);
    var existingFlight = _items[existingFlightIndex];
    _items.removeAt(existingFlightIndex);
    notifyListeners();

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 400) {
      _items.insert(existingFlightIndex, existingFlight);
      notifyListeners();
      throw Exception('No se pudo eliminar el vuelo.');
    }
  }
}
