import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class FollowupService {
  static const _baseUrl = 'https://visioncare.onrender.com';

  static Future<List<dynamic>> getPendingFollowups() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/followups/pending'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception('Failed to load followups');
  }
}
