class Api {
  static const String baseUrl = 'http://192.168.100.9:8000/api';

  /// Convierte una ruta de imagen del backend (/media/...) en URL absoluta.
  /// Devuelve null si no hay foto.
  static String? mediaUrl(dynamic path) {
    if (path == null) return null;
    final p = path.toString();
    if (p.isEmpty) return null;
    if (p.startsWith('http')) return p;
    return baseUrl.replaceAll('/api', '') + (p.startsWith('/') ? p : '/$p');
  }
}
