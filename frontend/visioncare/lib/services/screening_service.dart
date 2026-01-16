import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ScreeningService {
  static const _baseUrl = 'https://visioncare.onrender.com'; 

  static Future<Map<String, dynamic>> createScreening({
    required Uint8List imageBytes,
  }) async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/api/v1/screenings/');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      http.MultipartFile.fromBytes(
        'file', 
        imageBytes,
        filename: 'eye.jpg',
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Screening failed (${response.statusCode}): ${response.body}',
      );
    }
  }
}
