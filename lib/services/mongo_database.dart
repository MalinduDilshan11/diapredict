import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MongoDatabase {
  // Smart base URL based on platform
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Android emulator: use special alias to reach host PC
      return 'http://10.0.2.2:3000';
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop: localhost
      return 'http://localhost:3000';
    }

    // Fallback (web or other platforms)
    return 'http://localhost:3000';
  }

  /// Signup: Sends name, email, password to backend
  static Future<Map<String, dynamic>> insertUser(
    String name,
    String email,
    String password,
  ) async {
    try {
      print('🌍 Sending signup request to: $baseUrl/signup');

      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 20));

      final Map<String, dynamic> data = jsonDecode(response.body);
      print('✅ Signup response: $data');
      return data;
    } catch (e) {
      print('❌ Signup failed: $e');
      return {
        'success': false,
        'message': 'Cannot connect to server. Please check your network and backend.',
      };
    }
  }

  /// Login: Returns full response including 'name' from backend
  static Future<Map<String, dynamic>> findUser(
    String email,
    String password,
  ) async {
    try {
      print('🌍 Sending login request to: $baseUrl/login');

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 20));

      final Map<String, dynamic> data = jsonDecode(response.body);
      print('✅ Login response: $data');

      // Ensure 'name' is always present (fallback to 'User' if missing)
      if (data['success'] == true && data['name'] == null) {
        data['name'] = 'User';
      }

      return data;
    } catch (e) {
      print('❌ Login failed: $e');
      return {
        'success': false,
        'message': 'Cannot connect to server. Please check your network and backend.',
        'name': 'User', // fallback
      };
    }
  }
}