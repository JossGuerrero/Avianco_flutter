class Api {
  static const String baseUrl = 'https://jguerrer.me/api';

  static String? mediaUrl(dynamic path) {
    if (path == null) return null;
    final p = path.toString();
    if (p.isEmpty) return null;
    if (p.startsWith('http')) return p;
    return baseUrl.replaceAll('/api', '') + (p.startsWith('/') ? p : '/$p');
  }
}
