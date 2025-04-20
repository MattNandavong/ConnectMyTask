import 'dart:convert';
import 'dart:io';
import 'package:app/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl =
      'http://localhost:3300/api/auth'; // Update for device/emulator use

  Future<User> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
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

    return await _handleResponse(response);
  }

  Future<User> login(String email, String password) async {
    final url = '$baseUrl/login';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return await _handleResponse(response);
  }

  Future<User> _handleResponse(http.Response response) async {
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final user = User.fromJson(responseData['user']);
      print(' User after parsing: ${user.toJson()}');
      await saveUserSession(responseData['token'], user); // Clean call
      return user;
    } else {
      throw Exception(responseData['msg'] ?? 'Authentication failed.');
    }
  }

  Future<User> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    print('Loaded from SharedPreferences: $userJson');
    
    return User.fromJson(jsonDecode(userJson!));
    
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  Future<void> saveUserSession(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', jsonEncode(user.toJson()));
    print('📦 Saving to SharedPreferences: ${user.toJson()}');
  }
}
