import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/model/task.dart';
import 'package:app/model/user.dart';
import 'package:app/utils/task_service.dart';

class ProviderTaskDetail extends StatelessWidget {
  final String taskId;

  ProviderTaskDetail({required this.taskId});

  final formatter = DateFormat.yMMMMd();

  Future<User?> _getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Details')),
      body: FutureBuilder<Task>(
        future: TaskService().getTask(taskId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('Task not found'));
          }

          final task = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text('Title: ${task.title}', style: TextStyle(fontSize: 20)),
                SizedBox(height: 10),
                Text('Description: ${task.description}'),
                SizedBox(height: 10),
                Text('Budget: \$${task.budget}'),
                SizedBox(height: 10),
                Text('Deadline: ${formatter.format(task.deadline)}'),
                SizedBox(height: 10),
                Text('Posted by: ${task.user.name} (${task.user.email})'),
                SizedBox(height: 24),

                // Status Update Button Only for Assigned Provider
                FutureBuilder<User?>(
                  future: _getCurrentUser(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) return SizedBox();

                    final currentUser = userSnapshot.data!;
                    final isAssignedProvider = task.assignedProvider == currentUser.id;

                    if (!isAssignedProvider) return SizedBox();

                    final isCompleted = task.status.toLowerCase() == 'completed';
                    final newStatus = isCompleted ? 'In Progress' : 'Completed';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(),
                        Text("Update Task Status:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isCompleted ? Colors.orange : Colors.green,
                          ),
                          onPressed: () async {
                            try {
                              await TaskService().updateTaskStatus(task.id, newStatus);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Task marked as $newStatus')),
                              );

                              // Refresh page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProviderTaskDetail(taskId: task.id),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                          child: Text(isCompleted
                              ? 'Mark as In Progress'
                              : 'Mark as Completed'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
