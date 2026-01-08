import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class MongoDatabase {
  // Smart base URL selection
  static String get baseUrl {
    // Android emulator → use special alias for host machine
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }

    // Desktop platforms (Windows, macOS, Linux) → localhost
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return 'http://localhost:3000';
    }

    // Fallback (e.g., web or future platforms)
    return 'http://localhost:3000';
  }

  /// Signup: Now includes 'name' field
  static Future<Map<String, dynamic>> insertUser(
      String name, String email, String password) async {
    try {
      print('🌍 Connecting to: $baseUrl/signup'); // Debug log
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15)); // Prevent hanging

      final Map<String, dynamic> data = jsonDecode(response.body);
      print('✅ Signup response: $data');
      return data;
    } catch (e) {
      print('❌ Signup error: $e');
      return {
        'success': false,
        'message': 'Cannot reach server. Check backend and network.',
      };
    }
  }

  /// Login: Still only email + password (name not needed for login)
  static Future<Map<String, dynamic>> findUser(String email, String password) async {
    try {
      print('🌍 Connecting to: $baseUrl/login'); // Debug log
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      final Map<String, dynamic> data = jsonDecode(response.body);
      print('✅ Login response: $data');
      return data;
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false,
        'message': 'Cannot reach server. Check backend and network.',
      };
    }
  }
}