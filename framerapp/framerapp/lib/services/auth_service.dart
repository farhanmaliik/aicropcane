// services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:framerapp/models/auth_request_model.dart';
import 'package:framerapp/models/user_model.dart';

import '../models/auth_response_model.dart';

class AuthService {
  static const String baseUrl = 'https://yourapi.com/api';

  // ✅ LOGIN
  Future<UserModel> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  // ✅ REGISTER
  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return AuthResponse.fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'Registration failed');
    }
  }

  // ✅ LOGOUT
  Future<void> logout(String token) async {
    await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  // ✅ GET CURRENT USER
  Future<UserModel> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get profile');
    }
  }
}