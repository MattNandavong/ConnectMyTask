import 'dart:convert';
import 'dart:io';
import 'package:app/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://localhost:3300/api/auth';

  /// Register user (with optional profile photo & skills)
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? location,
    List<String>? skills,
    File? profilePhoto,
  }) async {
    final uri = Uri.parse('$baseUrl/register');
    final request = http.MultipartRequest('POST', uri);

    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['role'] = role;

    if (location != null) request.fields['location'] = location;
    if (skills != null && skills.isNotEmpty) {
      request.fields['skills'] = skills.join(',');
    }

    if (profilePhoto != null) {
      final stream = http.ByteStream(profilePhoto.openRead());
      final length = await profilePhoto.length();
      final file = http.MultipartFile(
        'profilePhoto',
        stream,
        length,
        filename: profilePhoto.path.split('/').last,
      );
      request.files.add(file);
    }

    final response = await request.send();
    final result = await http.Response.fromStream(response);

    if (result.statusCode == 200 || result.statusCode == 201) {
      final data = jsonDecode(result.body);
      final user = User.fromJson(data['user']);
      await saveUserSession(data['token'], user);
      return user;
    } else {
      final error = jsonDecode(result.body);
      throw Exception(error['msg'] ?? 'Registration failed');
    }
  }

  /// Login with email/password
  Future<User> login(String email, String password) async {
    final url = '$baseUrl/login';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final user = User.fromJson(data['user']);
      await saveUserSession(data['token'], user);
      return user;
    } else {
      throw Exception(data['msg'] ?? 'Login failed');
    }
  }

  /// Save user session
  Future<void> saveUserSession(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', jsonEncode(user.toJson()));
  }

  /// Load user from local storage
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  /// Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  /// Is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  /// Get token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Fetch full profile (GET /profile/:id)
  Future<User> getUserProfile(String userId) async {
    final token = await getToken();
    if (token == null) throw Exception('Token missing');

    final response = await http.get(
      Uri.parse('$baseUrl/profile/$userId'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }

  /// Update profile (PUT /profile/:id)
  Future<User> updateUserProfile({
    required String userId,
    String? name,
    String? location,
    List<String>? skills,
    File? profilePhoto,
  }) async {
    final token = await getToken();
    if (token == null) throw Exception('Token missing');

    final uri = Uri.parse('$baseUrl/profile/$userId');
    final request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = token;

    if (name != null) request.fields['name'] = name;
    if (location != null) request.fields['location'] = location;
    if (skills != null && skills.isNotEmpty) {
      request.fields['skills'] = skills.join(',');
    }

    if (profilePhoto != null) {
      final stream = http.ByteStream(profilePhoto.openRead());
      final length = await profilePhoto.length();
      final file = http.MultipartFile(
        'profilePhoto',
        stream,
        length,
        filename: profilePhoto.path.split('/').last,
      );
      request.files.add(file);
    }

    final response = await request.send();
    final result = await http.Response.fromStream(response);

    if (result.statusCode == 200) {
      final data = jsonDecode(result.body)['user'];
      final updatedUser = User.fromJson(data);
      await saveUserSession(token, updatedUser);
      return updatedUser;
    } else {
      throw Exception('Failed to update profile');
    }
  }
}
