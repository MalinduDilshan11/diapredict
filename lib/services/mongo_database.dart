import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MongoDatabase {
  /// Automatically choose base URL depending on device
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Emulator Android uses this to reach host machine
      return 'http://10.0.2.2:3000';
    }
    // iOS simulator or real device
    return 'http://192.168.8.199:3000';
  }

  /// Signup user
  static Future<Map<String, dynamic>> insertUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error connecting to backend: $e'};
    }
  }

  /// Login user
  static Future<Map<String, dynamic>> findUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error connecting to backend: $e'};
    }
  }
}
