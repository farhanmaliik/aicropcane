// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherProvider with ChangeNotifier {
  Map<String, dynamic>? _weatherData;
  String _cityName = "Faisalabad";
  bool _isLoading = false;

  Map<String, dynamic>? get weatherData => _weatherData;
  String get cityName => _cityName;
  bool get isLoading => _isLoading;

  Future<void> fetchWeatherData({
    double lat = 31.4181, 
    double lon = 73.0791,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      
      final url = Uri.parse(
        "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true",
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        _weatherData = jsonDecode(response.body);
      }

      
      final geoUrl = Uri.parse(
        "https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json",
      );

      final geoResponse = await http.get(geoUrl, headers: {
        "User-Agent": "FlutterApp"
      });

      if (geoResponse.statusCode == 200) {
        final geoData = jsonDecode(geoResponse.body);
        _cityName = geoData["address"]["city"] ??
            geoData["address"]["town"] ??
            geoData["address"]["village"] ??
            "Unknown";
      }
    } catch (e) {
      debugPrint("🔥 Weather fetch error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
