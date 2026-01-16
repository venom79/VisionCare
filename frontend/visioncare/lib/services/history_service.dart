import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class HistoryService {
  static const _baseUrl = 'https://visioncare.onrender.com';

  static Future<List<dynamic>> getMyScreenings() async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/screenings/my'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception(
        'Failed to load history (${response.statusCode})',
      );
    }
  }
  
  static Future<Map<String, dynamic>> getScreeningDetail(String screeningId) async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/screenings/$screeningId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to load screening detail (${response.statusCode})',
      );
    }
  }
}
