import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {

  
  static String baseUrl = kIsWeb
      ? "http://localhost:3000"
      : "http://10.0.2.2:3000";

  // ---------------- SIGNUP ----------------
  static Future<Map<String, dynamic>> signup(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Signup failed: $e"};
    }
  }

  // ---------------- LOGIN ----------------
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Login failed: $e"};
    }
  }

  // ---------------- SAVE RISK ----------------
  static Future<Map<String, dynamic>> saveRisk(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/risk"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Risk save failed: $e"};
    }
  }

  // ---------------- SAVE PREDICTION ----------------
  static Future<Map<String, dynamic>> savePrediction(
      String email, String predictedRisk) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/prediction"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "predictedRisk": predictedRisk,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Prediction save failed: $e"};
    }
  }

  // ---------------- GET PREDICTION ----------------
  static Future<Map<String, dynamic>> getPrediction(String email) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/prediction/$email"),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Fetch prediction failed: $e"};
    }
  }
}