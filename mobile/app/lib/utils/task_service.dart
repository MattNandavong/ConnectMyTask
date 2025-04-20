import 'dart:convert';
import 'package:app/model/task.dart';
import 'package:app/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TaskService {
  final String baseUrl = 'http://localhost:3300/api/tasks';

  Future<List<Task>> getAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      print(data);
      return data.map((taskJson) => Task.fromJson(taskJson)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<Task> getTask(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
    );

    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load task');
    }
  }

  Future<Map<String, dynamic>> createTask(
    String title,
    String description,
    double budget,
    String deadline,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({
        'title': title,
        'description': description,
        'budget': budget,
        'deadline': deadline,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create task');
    }
  }

  Future<void> updateTaskStatus(String id, String status) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/$id/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      final responseBody = response.body;

      // Try parsing error message
      try {
        final errorData = jsonDecode(responseBody);
        final message = errorData['msg'] ?? 'Unknown error occurred';
        throw Exception('Failed to update status: $message');
      } catch (e) {
        // If response body is not JSON, show fallback
        throw Exception(
          'Failed to update status: ${response.reasonPhrase} (code: ${response.statusCode})',
        );
      }
    }

    // Optional: Log success
    print('Task status updated to "$status"');
  } catch (e) {
    // Log & rethrow the actual error
    print('Error in updateTaskStatus: $e');
    throw e;
  }
}

  Future<void> deleteTask(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }

  Future<void> bidOnTask(String id, double price, String estimatedTime) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/$id/bid'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'price': price, 'estimatedTime': estimatedTime}),
    );

    if (response.statusCode == 403) {
      throw Exception('Authorization failed');
    } else if (response.statusCode != 200) {
      throw Exception('Failed to bid on task');
    }
  }

  Future<void> completeTask(String id, double rating, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/$id/completeTask'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'rating': rating, 'comment': comment}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to complete task');
    }
  }

  Future<List<Task>> getUserTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString == null) {
      print('No user found in SharedPreferences');
      return [];
    }
    final user = jsonDecode(userString);
    final userId = user['_id'];
    final tasks = await getAllTasks();
    final userTasks = tasks.where((task) => task.user.id == userId).toList();
    // print('User tasks: $userTasks');

    return userTasks;
  }

 Future<List<Task>> getProviderTask() async {
  final prefs = await SharedPreferences.getInstance();
  final userString = prefs.getString('user');

  if (userString == null) {
    print('No user found in SharedPreferences');
    return [];
  }

  final user = User.fromJson(jsonDecode(userString));
  final userId = user.id;

  final tasks = await getAllTasks();

  final List<Task> providerTasks = tasks.where((task) {
    final isAssigned = task.assignedProvider == userId;
    final hasBid = task.bids.any((bid) => bid.provider == userId);
    return isAssigned || hasBid;
  }).toList();

  return providerTasks;
}


  Future<void> acceptBid(String taskId, String bidId) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/$taskId/acceptBid/$bidId'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to accept bid');
    }
  }

  Future<String> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) throw Exception('No token found');
  return token;
}



}
