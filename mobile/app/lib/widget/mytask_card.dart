import 'dart:convert';

import 'package:app/model/task.dart';
import 'package:app/utils/auth_helper.dart';
import 'package:app/widget/my_task/provider_task_detail.dart';
import 'package:app/widget/my_task/task_detail.dart';
import 'package:app/widget/task_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/utils/task_card_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTaskCard extends StatelessWidget {
  const MyTaskCard({super.key, required this.task});

  final Task task;
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
            builder: (context) => MyTaskDetails(taskId: taskId),
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
      color: Colors.white,
      child: InkWell(
        onTap: () => navigateToTaskDetailByRole(context, task.id),

        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [TaskCardHelpers.getStatusText(task.status, 12)],
              ),
              Row(
                children: [
                  TaskCardHelpers.getTaskDetail(
                    task.title,
                    task.description,
                    task.budget,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
