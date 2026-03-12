import 'dart:convert';
import 'package:http/http.dart' as http;

class MongoDatabase {

  // IMPORTANT: Use  PC IP address
  static const String baseUrl = "http://10.63.63.66:3000";

  /// ---------------- SIGNUP ----------------
  static Future<Map<String, dynamic>> insertUser(
      String name,
      String email,
      String password,
      ) async {
    try {

      print("Sending signup request to $baseUrl/signup");

      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name.trim(),
          "email": email.trim(),
          "password": password
        }),
      );

      final data = jsonDecode(response.body);

      print("Signup response: $data");

      return data;

    } catch (e) {

      print("Signup error: $e");

      return {
        "success": false,
        "message": "Cannot connect to server. Please check your network and backend."
      };
    }
  }

  /// ---------------- LOGIN ----------------
  static Future<Map<String, dynamic>> findUser(
      String email,
      String password,
      ) async {

    try {

      print("Sending login request to $baseUrl/login");

      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.trim(),
          "password": password
        }),
      );

      final data = jsonDecode(response.body);

      print("Login response: $data");

      return data;

    } catch (e) {

      print("Login error: $e");

      return {
        "success": false,
        "message": "Cannot connect to server. Please check your network and backend."
      };
    }
  }

  /// ---------------- SAVE RISK ----------------
  static Future<Map<String, dynamic>> saveRiskAssessment({
    required String email,
    required String ageGroup,
    required String gender,
    required double height,
    required double weight,
    required double bmi,
    required bool highBP,
    required bool highChol,
    required String generalHealth,
    required bool physActivity,
    required bool fruits,
    required bool veggies,
    required bool diffWalk,
  }) async {

    try {

      String yesNo(bool val) => val ? "Yes" : "No";

      final response = await http.post(
        Uri.parse("$baseUrl/risk"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "Age": ageGroup,
          "Sex": gender,
          "Height": height,
          "Weight": weight,
          "BMI": bmi,
          "HighBP": yesNo(highBP),
          "HighChol": yesNo(highChol),
          "GenHlth": generalHealth,
          "PhysActivity": yesNo(physActivity),
          "Fruits": yesNo(fruits),
          "Veggies": yesNo(veggies),
          "DiffWalk": yesNo(diffWalk),
        }),
      );

      final data = jsonDecode(response.body);

      print("Risk save response: $data");

      return data;

    } catch (e) {

      print("Risk save error: $e");

      return {
        "success": false,
        "message": "Failed to save risk assessment"
      };
    }
  }

}