import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class DoctorService {
  static const _baseUrl = 'https://visioncare.onrender.com';

  static Future<List<dynamic>> getPendingReviews() async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/doctor/dashboard/pending'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load pending reviews');
    }
  }
}
