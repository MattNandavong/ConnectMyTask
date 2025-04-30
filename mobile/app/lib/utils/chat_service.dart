import 'dart:convert';
import 'package:app/model/chat_preview.dart'; // Define ChatMessage and ChatPreview models accordingly
import 'package:app/utils/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  // static const String baseUrl = 'http://10.0.2.2:3300/api/chat';
  //Real device
  // final String baseUrl = 'http://192.168.1.101:3300/api/chat';
  final String baseUrl = 'http://192.168.1.101:3300/api/messages';

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token not found');
    return token;
  }

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final user = jsonDecode(prefs.getString('user') ?? '{}');
    return user['_id'] ?? user['id'];
  }

  Future<List<ChatPreview>> getChatHistory(String taskId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$taskId'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => ChatPreview.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chat history');
    }
  }

  // Future<List<ChatPreview>> getChatSummary() async {
  //   final userId = await _getUserId();
  //   final response = await http.get(Uri.parse('$baseUrl/summary/$userId'));

  //   if (response.statusCode == 200) {
  //     final List data = jsonDecode(response.body);
  //     return data.map((json) => ChatPreview.fromJson(json)).toList();
  //   } else {
  //     throw Exception('Failed to load chat summary');
  //   }
  // }

  Future<List<ChatPreview>> getChatSummary() async {
  final userId = await _getUserId();
  final token = await _getToken();
  
  final response = await http.get(
    Uri.parse('$baseUrl/summary/$userId'),
    headers: {
      'Authorization': '$token',
    },
  );

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((json) => ChatPreview.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load chat summary');
  }
}

  // Optional: Fallback HTTP POST if WebSocket not available
  // Future<void> sendMessage(String taskId, String text) async {
  //   final userId = await _getUserId();
  //   final token = await AuthService().getToken();
  //   final response = await http.post(
  //     // Uri.parse('$baseUrl/send'), // Only if you implement this endpoint
  //     Uri.parse('$baseUrl/$taskId'),
  //     headers: {'Content-Type': 'application/json', 'Authorization': '$token'},
  //     body: jsonEncode({'taskId': taskId, 'sender': userId, 'text': text, 'receiverId': receiverId, }),
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception('Failed to send message');
  //   }
  // }
}
