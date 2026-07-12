import 'package:flutter_dotenv/flutter_dotenv.dart';

class Api {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'https://jguerrer.me/api';
}
