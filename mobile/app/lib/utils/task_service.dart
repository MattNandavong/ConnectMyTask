import 'dart:convert';
import 'dart:io';
import 'package:app/model/task.dart';
import 'package:app/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class TaskService {
  // final String baseUrl = 'http://10.0.2.2:3300/api/tasks';

  //Real device
  final String baseUrl = 'http://192.168.1.101:3300/api/tasks';

  Future<List<Task>> getAllTasks() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return await Future.wait(data.map((json) => Task.fromJsonAsync(json)));
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<Task> getTask(String id) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      return await Task.fromJsonAsync(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load task');
    }
  }

  Future<Map<String, dynamic>> createTask({
    required String title,
    required String description,
    required double budget,
    required String? deadline,
    required String category,
    required Map<String, dynamic> location,
    required List<File> images,
  }) async {
    final token = await _getToken(); // Your method to get the auth token

    var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.headers['Authorization'] = token;

    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['budget'] = budget.toString();
    if (deadline != null) {
      request.fields['deadline'] = deadline; // Only send if not null
    }
    request.fields['category'] = category;

    request.fields['location'] = jsonEncode(location);

    for (var image in images) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    print("📤 Submitting Task with fields:");
    request.fields.forEach((key, value) => print("  $key: $value"));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      print('❌ Error Response: ${response.body}');
      throw Exception('Failed to create task');
    }
  }

  Future<void> updateTaskStatus(String id, String status) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/$id/status'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update status');
    }
  }

  Future<void> deleteTask(String id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': token},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }

  Future<void> bidOnTask(
    String id,
    double price,
    String estimatedTime, {
    String? comment,
  }) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/$id/bid'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({
        'price': price,
        'estimatedTime': estimatedTime,
        if (comment != null) 'comment': comment, //only send if not null
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to bid on task');
    }
  }

  Future<void> completeTask(String id, double rating, String comment) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/$id/completeTask'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'rating': rating, 'comment': comment}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to complete task');
    }
  }

  Future<void> acceptBid(String taskId, String bidId) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/$taskId/acceptBid/$bidId'),
      headers: {'Authorization': token, 'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to accept bid');
    }
  }

  Future<List<Task>> getUserTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final user = jsonDecode(prefs.getString('user') ?? '{}');
    final userId = user['id'] ?? user['_id'];
    final tasks = await getAllTasks();
    return tasks.where((task) => task.user.id == userId).toList();
  }

  Future<List<Task>> getProviderTask() async {
    final prefs = await SharedPreferences.getInstance();
    final user = jsonDecode(prefs.getString('user') ?? '{}');
    final userId = user['id'] ?? user['_id'];

    final tasks = await getAllTasks();

    return tasks.where((task) {
      final assignedProviderId = task.assignedProvider;
      final matchesAssigned = assignedProviderId == userId;

      final matchesBid = task.bids.any((bid) => bid.provider == userId);

      return matchesAssigned || matchesBid;
    }).toList();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('No token found');
    return token;
  }

  Future<List<dynamic>> getTaskComments(String taskId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$taskId'),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      final task = jsonDecode(response.body);
      return task['comments'] ?? [];
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<void> postComment(String taskId, String text) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/$taskId/comment'),
      headers: {'Authorization': token, 'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to post comment');
    }
  }

  Future<void> postReply(String taskId, String commentId, String text) async {
  final token = await _getToken();
  final response = await http.post(
    Uri.parse('$baseUrl/$taskId/comment/$commentId/reply'),
    headers: {
      'Authorization': token,
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'text': text}),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to post reply');
  }
}

}
