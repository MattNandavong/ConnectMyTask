import 'dart:convert';
import 'package:app/model/user.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = 'http://localhost:3300/api/auth';

  Future<User> getUserById(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/$userId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to load user');
    }
  }
}
