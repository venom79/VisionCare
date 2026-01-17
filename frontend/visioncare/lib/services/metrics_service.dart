import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class MetricsService {
  static const _baseUrl = 'https://visioncare.onrender.com';

  static Future<Map<String, dynamic>> getOverview() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/metrics/overview'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load metrics');
    }
  }
}
