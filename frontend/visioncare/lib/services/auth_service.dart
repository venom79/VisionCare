import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const _baseUrl = 'https://visioncare.onrender.com'; 
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access_token';

  // ================= LOGIN =================
  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/auth/login'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': email, // email as username
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final token = data['access_token'];
      final user = data['user'];

      if (token != null && user != null) {
        // 🔹 Normalize role
        final rawRole = user['role'].toString().toUpperCase();

        String normalizedRole;
        if (rawRole.contains('DOCTOR') || rawRole.contains('OPHTHALMOLOGY')) {
          normalizedRole = 'DOCTOR';
        } else {
          normalizedRole = 'PATIENT';
        }

        await _storage.write(key: _tokenKey, value: token);
        await _storage.write(key: 'user_id', value: user['id']);
        await _storage.write(key: 'user_role', value: normalizedRole);
        await _storage.write(key: 'user_name', value: user['full_name']);
        await _storage.write(key: 'user_email', value: user['email']);

        return true;
      }
    }

    return false;
  }


 // ================= REGISTER =================
  static Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }


  // ================= TOKEN =================
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: 'user_role');
    await _storage.delete(key: 'user_name');
    await _storage.delete(key: 'user_id');
  }


  static Future<bool> isLoggedIn() async {
    return await getToken() != null;
  }

  static Future<String?> getUserRole() async {
    return await _storage.read(key: 'user_role');
  }

  static Future<String?> getUserName() async {
    return await _storage.read(key: 'user_name');
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  } 

  static Future<String?> getUserEmail() async {
    return await _storage.read(key: 'user_email');
  }


}

