import 'package:flutter/material.dart';
import 'package:avianco/services/api_service.dart';

class DashboardProvider with ChangeNotifier {
  Map<String, int> _stats = {
    'vuelos': 0,
    'reservas': 0,
    'pasajeros': 0,
    'aeropuertos': 0,
  };
  bool _isLoading = false;

  Map<String, int> get stats => _stats;
  bool get isLoading => _isLoading;

  Future<void> fetchStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        ApiService.getVuelosCount(),
        ApiService.getReservasCount(),
        ApiService.getPasajerosCount(),
        ApiService.getAeropuertosCount(),
      ]);

      _stats = {
        'vuelos': results[0],
        'reservas': results[1],
        'pasajeros': results[2],
        'aeropuertos': results[3],
      };
    } catch (error) {
      print('Dashboard error: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
