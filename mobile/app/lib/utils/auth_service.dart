import 'dart:convert';
import 'package:app/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://localhost:3300/api/auth';

  Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    final url = '$baseUrl/register';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', responseData['token']);
      await prefs.setString('user', jsonEncode(responseData['user']));
      return responseData;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['msg'] ?? 'Authentication failed.');
    }
  }

 Future<Map<String, dynamic>> login(String email, String password) async {
    final url = '$baseUrl/login';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return _handleResponse(response);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }
}
