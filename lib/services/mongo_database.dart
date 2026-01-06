import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MongoDatabase {

  static String get baseUrl {
    // Android emulator
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }

    // Windows 
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return 'http://localhost:3000';
    }

    // Web or wena mokakhari
    return 'http://localhost:3000';
  }

  static Future<Map<String, dynamic>> insertUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error connecting to backend: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> findUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error connecting to backend: $e',
      };
    }
  }
}