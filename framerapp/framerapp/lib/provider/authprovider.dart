import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:framerapp/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  bool _isLoading = false;

  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuth => _token != null;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("auth_token");
    debugPrint("🔄 Loaded token from local storage: $_token");
    notifyListeners();
  }

  Future<bool> signUp({
    required String username,
    required String email,
    required String password,
    String? role,
  }) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse("$baseUrl/create-user");
    final body = {
      "username": username,
      "email": email,
      "password": password,
      if (role != null) "role": role,
    };

    try {
      debugPrint("📤 Signup request: $body");

      final response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("📥 Signup response: ${response.statusCode} ${response.body}");

      final data = jsonDecode(response.body);
      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Signup successful for $username");
        return true;
      } else {
        throw data["message"] ?? "Signup failed";
      }
    } catch (e) {
      debugPrint("❌ Signup error: $e");
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse("$baseUrl/login");
    final body = {"username": username, "password": password};

    try {
      debugPrint("📤 Login request: $body");

      final response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("📥 Login response: ${response.statusCode} ${response.body}");

      final data = jsonDecode(response.body);
      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        _token = data["token"];
        debugPrint("✅ Login successful. Token: $_token");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("auth_token", _token!);
        debugPrint("💾 Token saved in SharedPreferences");

        notifyListeners();
        return true;
      } else {
        throw data["message"] ?? "Login failed";
      }
    } catch (e) {
      debugPrint("❌ Login error: $e");
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> changepassword({
    required String username,
    required String email,
    required String oldPassword,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
      "$baseUrl/Change-password",
    );
    final body = {
      "username": username,
      "email": email,
      "oldPassword": oldPassword,
      "newPassword": password,
    };

    try {
      debugPrint("📤 change password request: $body");

      final response = await http.patch(
        url,
        body: jsonEncode(body),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
      );

      debugPrint(
        "📥 change password response: ${response.statusCode} ${response.body}",
      );

      final data = jsonDecode(response.body);
      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        debugPrint("💾 Token saved in SharedPreferences");

        notifyListeners();
        return true;
      } else {
        throw data["message"] ?? "Login failed";
      }
    } catch (e) {
      debugPrint("❌ Login error: $e");
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    debugPrint("🚪 Logged out, token removed from SharedPreferences");
  }
}
