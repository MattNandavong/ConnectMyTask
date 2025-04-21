import 'dart:convert';
import 'package:app/widget/my_task/myTask_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:app/widget/my_task/provider_task_detail.dart';
import 'package:app/widget/task_detail_screen.dart';

Future<void> navigateToTaskDetailByRole(BuildContext context, String taskId) async {
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('user');

  if (userJson != null) {
    final user = jsonDecode(userJson);
    final role = user['role'];

    if (role == 'provider') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProviderTaskDetail(taskId: taskId),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyTaskDetails(taskId: taskId),
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User not logged in.')),
    );
  }
}
