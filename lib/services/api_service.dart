import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    try {
      var response = await http.get(
        Uri.parse('${Api.baseUrl}/vuelos/?estado=programado'),
        headers: {'Content-Type': 'application/json'},
      );
      debugPrint(
        'getVuelosPublico [${response.statusCode}]: '
        '${response.body.length > 300 ? response.body.substring(0, 300) : response.body}',
      );
      if (response.statusCode == 200) {
        final results = jsonDecode(response.body)['results'];
        if (results is List && results.isNotEmpty) return results;
        // Sin vuelos programados: trae todos para no dejar la pantalla vacía
        response = await http.get(
          Uri.parse('${Api.baseUrl}/vuelos/'),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          final all = jsonDecode(response.body)['results'];
          if (all is List) return all;
        }
      }
    } catch (e) {
      debugPrint('getVuelosPublico error: $e');
    }
    return [];
  }

  static Future<List<dynamic>> getPromocionesPublico() async {
    try {
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/promociones/?activa=true'),
        headers: {'Content-Type': 'application/json'},
      );
      debugPrint('getPromocionesPublico [${response.statusCode}]');
      if (response.statusCode == 200) {
        final results = jsonDecode(response.body)['results'];
        if (results is List) return results;
      }
    } catch (e) {
      debugPrint('getPromocionesPublico error: $e');
    }
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

  static Future<List<dynamic>> getAsientosPorVuelo(int vueloId) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('${Api.baseUrl}/asientos/?vuelo=$vueloId'),
      headers: headers,
    );
    if (response.statusCode == 200) return jsonDecode(response.body)['results'];
    return [];
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

  // METODOS DE PAGO
  static Future<List<dynamic>> getMetodosPago() async {
    try {
      final headers = await _headers();
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/metodos-pago/'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map && body['results'] is List) return body['results'];
        if (body is List) return body;
      }
    } catch (e) {
      debugPrint('getMetodosPago error: $e');
    }
    return [];
  }

  static Future<List<dynamic>> getMetodosPagoActivos() async {
    final metodos = await getMetodosPago();
    final activos = metodos
        .where((m) => m['activo'] == true || m['activa'] == true)
        .toList();
    return activos.isNotEmpty ? activos : metodos;
  }

  // PAGOS
  static Future<Map<String, dynamic>?> createPago(
    Map<String, dynamic> data,
  ) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/pagos/'),
      headers: headers,
      body: jsonEncode(data),
    );
    debugPrint('createPago [${response.statusCode}]: ${response.body}');
    if (response.statusCode == 201 || response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) return body;
      return {};
    }
    return null;
  }

  // Variantes que devuelven el objeto creado (se necesita el id)
  static Future<Map<String, dynamic>?> createReservaDetalle(
    Map<String, dynamic> data,
  ) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/reservas/'),
      headers: headers,
      body: jsonEncode(data),
    );
    debugPrint('createReserva [${response.statusCode}]: ${response.body}');
    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) return body;
      return {};
    }
    return null;
  }

  static Future<Map<String, dynamic>?> createFacturaDetalle(
    Map<String, dynamic> data,
  ) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/facturas/'),
      headers: headers,
      body: jsonEncode(data),
    );
    debugPrint('createFactura [${response.statusCode}]: ${response.body}');
    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) return body;
      return {};
    }
    return null;
  }

  // USUARIOS (mejor esfuerzo: prueba varios endpoints comunes)
  static Future<List<dynamic>> getUsuarios() async {
    for (final ep in ['usuarios', 'auth/usuarios', 'users']) {
      try {
        final headers = await _headers();
        final response = await http.get(
          Uri.parse('${Api.baseUrl}/$ep/'),
          headers: headers,
        );
        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          if (body is Map && body['results'] is List) return body['results'];
          if (body is List) return body;
        }
      } catch (_) {
        // Prueba el siguiente endpoint
      }
    }
    return [];
  }

  // ---------- CATALOGOS Y TABLAS SECUNDARIAS ----------
  static Future<List<dynamic>> _getList(String pathAndQuery) async {
    try {
      final headers = await _headers();
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/$pathAndQuery'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map && body['results'] is List) return body['results'];
        if (body is List) return body;
      } else {
        debugPrint('GET /$pathAndQuery [${response.statusCode}]');
      }
    } catch (e) {
      debugPrint('GET /$pathAndQuery error: $e');
    }
    return [];
  }

  static Future<bool> _post(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _headers();
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/$endpoint/'),
        headers: headers,
        body: jsonEncode(data),
      );
      debugPrint('POST /$endpoint [${response.statusCode}]: ${response.body}');
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('POST /$endpoint error: $e');
      return false;
    }
  }

  static Future<List<dynamic>> getTiposAvion() => _getList('tipos-avion/');
  static Future<bool> createTipoAvion(Map<String, dynamic> data) =>
      _post('tipos-avion', data);

  static Future<List<dynamic>> getTerminales() => _getList('terminales/');
  static Future<List<dynamic>> getPuertas({int? terminal}) => _getList(
        terminal == null
            ? 'puertas/'
            : 'puertas/?terminal=$terminal&activa=true',
      );

  static Future<List<dynamic>> getPaises() => _getList('paises/');
  static Future<bool> createPais(Map<String, dynamic> data) =>
      _post('paises', data);
  static Future<List<dynamic>> getCiudades({int? pais}) =>
      _getList(pais == null ? 'ciudades/' : 'ciudades/?pais=$pais');
  static Future<bool> createCiudad(Map<String, dynamic> data) =>
      _post('ciudades', data);

  static Future<List<dynamic>> getEscalasPorVuelo(int vueloId) =>
      _getList('escalas/?vuelo=$vueloId');
  static Future<List<dynamic>> getEstadosVueloPorVuelo(int vueloId) =>
      _getList('estados-vuelo/?vuelo=$vueloId');

  static Future<List<dynamic>> getAsignaciones() => _getList('asignaciones/');
  static Future<bool> createAsignacion(Map<String, dynamic> data) =>
      _post('asignaciones', data);

  static Future<List<dynamic>> getNotificaciones() =>
      _getList('notificaciones/');
  static Future<bool> createNotificacion(Map<String, dynamic> data) =>
      _post('notificaciones', data);
  static Future<bool> marcarNotificacionLeida(int id) async {
    try {
      final headers = await _headers();
      final response = await http.patch(
        Uri.parse('${Api.baseUrl}/notificaciones/$id/'),
        headers: headers,
        body: jsonEncode({'leida': true}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> createReservaServicio(Map<String, dynamic> data) =>
      _post('reserva-servicios', data);
  static Future<bool> createEquipaje(Map<String, dynamic> data) =>
      _post('equipajes', data);

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
