import 'dart:convert';
import 'package:app/model/task.dart';
import 'package:app/widget/my_task/provider_task_detail.dart';
import 'package:flutter/material.dart';
import 'package:app/widget/browse_task/task_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/utils/task_card_helpers.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.context,
    required this.task,

  });

  final Task task;
  final context;

  void navigateToTaskDetailByRole(BuildContext context, String taskId) async {
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
            builder: (context) => TaskDetailScreen(taskId: taskId),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User not logged in.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Colors.white,
      child: InkWell(
        onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskDetailScreen(taskId: task.id),
        ),
      ),

        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TaskCardHelpers.getStatusText(task.status),

              TaskCardHelpers.getTaskDetail(context, task, false),
            ],
          ),
        ),
      ),
    );
  }
}
