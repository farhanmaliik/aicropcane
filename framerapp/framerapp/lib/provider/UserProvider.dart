// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:framerapp/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _userData;

  Map<String, dynamic>? get userData => _userData;

  //isloading state for user data fetch
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get isUserDataLoaded => _userData != null;

  Future<void> fetchUserData() async {
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token == null) return;

    final url = Uri.parse("$baseUrl/user");

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        final data = jsonDecode(response.body);
        _userData = data["user"];
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("❌ User fetch error: $e");
    }
  }
}
