import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'auth_service.dart';

class ApiService {
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<int> _count(String endpoint) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/$endpoint/'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is Map && body.containsKey('count')) return body['count'];
      if (body is List) return body.length;
    }
    return 0;
  }

  static Future<int> getVuelosCount() => _count('vuelos');
  static Future<int> getReservasCount() => _count('reservas');
  static Future<int> getPasajerosCount() => _count('pasajeros');
  static Future<int> getAeropuertosCount() => _count('aeropuertos');

  // ---------- ESTADISTICAS (devuelve {} si el endpoint falla) ----------
  static Future<Map<String, dynamic>> _getStats(String endpoint) async {
    try {
      final headers = await _headers();
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/$endpoint/estadisticas/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) return body;
        if (body is List) return {'results': body};
      }
    } catch (_) {
      // Endpoint no disponible: el dashboard muestra 0 o guion
    }
    return {};
  }

  static Future<Map<String, dynamic>> getReservasEstadisticas() =>
      _getStats('reservas');
  static Future<Map<String, dynamic>> getVuelosEstadisticas() =>
      _getStats('vuelos');
  static Future<Map<String, dynamic>> getAeronavesEstadisticas() =>
      _getStats('aeronaves');

  // ---------- ENDPOINTS PUBLICOS (sin token) ----------
  static Future<List<dynamic>> getVuelosPublico() async {
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/vuelos/?estado=programado'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) return jsonDecode(response.body)['results'];
    return [];
  }

  static Future<List<dynamic>> getPromocionesPublico() async {
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/promociones/?activa=true'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) return jsonDecode(response.body)['results'];
    return [];
  }

  // VUELOS
  static Future<List<dynamic>> getVuelos({
    String search = '',
    int page = 1,
  }) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/vuelos/?search=$search&page=$page'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body)['results'];
    return [];
  }

  static Future<bool> createVuelo(Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/vuelos/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateVuelo(int id, Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.patch(
      Uri.parse('${Api.baseUrl}/vuelos/$id/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteVuelo(int id) async {
    final headers = await _headers();
    final response = await http.delete(
      Uri.parse('${Api.baseUrl}/vuelos/$id/'),
      headers: headers,
    );
    return response.statusCode == 204;
  }

  // RESERVAS
  static Future<List<dynamic>> getReservas({int page = 1}) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/reservas/?page=$page'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body)['results'];
    return [];
  }

  static Future<bool> createReserva(Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/reservas/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateReserva(int id, Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.patch(
      Uri.parse('${Api.baseUrl}/reservas/$id/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteReserva(int id) async {
    final headers = await _headers();
    final response = await http.delete(
      Uri.parse('${Api.baseUrl}/reservas/$id/'),
      headers: headers,
    );
    return response.statusCode == 204;
  }

  // AEROPUERTOS
  static Future<List<dynamic>> getAeropuertos({String search = ''}) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/aeropuertos/?search=$search'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body)['results'];
    return [];
  }

  static Future<bool> createAeropuerto(Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/aeropuertos/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateAeropuerto(
    int id,
    Map<String, dynamic> data,
  ) async {
    final headers = await _headers();
    final response = await http.patch(
      Uri.parse('${Api.baseUrl}/aeropuertos/$id/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteAeropuerto(int id) async {
    final headers = await _headers();
    final response = await http.delete(
      Uri.parse('${Api.baseUrl}/aeropuertos/$id/'),
      headers: headers,
    );
    return response.statusCode == 204;
  }

  // AERONAVES
  static Future<List<dynamic>> getAeronaves({String search = ''}) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/aeronaves/?search=$search'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body)['results'];
    return [];
  }

  static Future<bool> createAeronave(Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/aeronaves/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateAeronave(int id, Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.patch(
      Uri.parse('${Api.baseUrl}/aeronaves/$id/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteAeronave(int id) async {
    final headers = await _headers();
    final response = await http.delete(
      Uri.parse('${Api.baseUrl}/aeronaves/$id/'),
      headers: headers,
    );
    return response.statusCode == 204;
  }

  // ASIENTOS
  static Future<List<dynamic>> getAsientos({String search = ''}) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/asientos/?search=$search'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body)['results'];
    return [];
  }

  static Future<bool> createAsiento(Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/asientos/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateAsiento(int id, Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.patch(
      Uri.parse('${Api.baseUrl}/asientos/$id/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteAsiento(int id) async {
    final headers = await _headers();
    final response = await http.delete(
      Uri.parse('${Api.baseUrl}/asientos/$id/'),
      headers: headers,
    );
    return response.statusCode == 204;
  }

  // PASAJEROS
  static Future<List<dynamic>> getPasajeros({String search = ''}) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/pasajeros/?search=$search'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body)['results'];
    return [];
  }

  static Future<bool> createPasajero(Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/pasajeros/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updatePasajero(int id, Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.patch(
      Uri.parse('${Api.baseUrl}/pasajeros/$id/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deletePasajero(int id) async {
    final headers = await _headers();
    final response = await http.delete(
      Uri.parse('${Api.baseUrl}/pasajeros/$id/'),
      headers: headers,
    );
    return response.statusCode == 204;
  }

  // TRIPULACION
  static Future<List<dynamic>> getTripulacion({String search = ''}) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/tripulacion/?search=$search'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body)['results'];
    return [];
  }

  static Future<bool> createTripulacion(Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/tripulacion/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateTripulacion(
    int id,
    Map<String, dynamic> data,
  ) async {
    final headers = await _headers();
    final response = await http.patch(
      Uri.parse('${Api.baseUrl}/tripulacion/$id/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteTripulacion(int id) async {
    final headers = await _headers();
    final response = await http.delete(
      Uri.parse('${Api.baseUrl}/tripulacion/$id/'),
      headers: headers,
    );
    return response.statusCode == 204;
  }

  // PROMOCIONES
  static Future<List<dynamic>> getPromociones() async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/promociones/'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body)['results'];
    return [];
  }

  static Future<bool> createPromocion(Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/promociones/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updatePromocion(int id, Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.patch(
      Uri.parse('${Api.baseUrl}/promociones/$id/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deletePromocion(int id) async {
    final headers = await _headers();
    final response = await http.delete(
      Uri.parse('${Api.baseUrl}/promociones/$id/'),
      headers: headers,
    );
    return response.statusCode == 204;
  }

  // FACTURAS
  static Future<List<dynamic>> getFacturas() async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/facturas/'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body)['results'];
    return [];
  }

  static Future<bool> createFactura(Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/facturas/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateFactura(int id, Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.patch(
      Uri.parse('${Api.baseUrl}/facturas/$id/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteFactura(int id) async {
    final headers = await _headers();
    final response = await http.delete(
      Uri.parse('${Api.baseUrl}/facturas/$id/'),
      headers: headers,
    );
    return response.statusCode == 204;
  }

  // SERVICIOS
  static Future<List<dynamic>> getServicios() async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/servicios/'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body)['results'];
    return [];
  }

  static Future<bool> createServicio(Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/servicios/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateServicio(int id, Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.patch(
      Uri.parse('${Api.baseUrl}/servicios/$id/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteServicio(int id) async {
    final headers = await _headers();
    final response = await http.delete(
      Uri.parse('${Api.baseUrl}/servicios/$id/'),
      headers: headers,
    );
    return response.statusCode == 204;
  }

  // CHECKINS
  static Future<List<dynamic>> getCheckins() async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/checkins/'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body)['results'];
    return [];
  }

  static Future<bool> createCheckin(Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/checkins/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateCheckin(int id, Map<String, dynamic> data) async {
    final headers = await _headers();
    final response = await http.patch(
      Uri.parse('${Api.baseUrl}/checkins/$id/'),
      headers: headers,
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteCheckin(int id) async {
    final headers = await _headers();
    final response = await http.delete(
      Uri.parse('${Api.baseUrl}/checkins/$id/'),
      headers: headers,
    );
    return response.statusCode == 204;
  }
}
