import 'dart:convert';
import 'package:app/model/task.dart';
import 'package:app/utils/task_service.dart';
import 'package:app/widget/my_task/mytask_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTaskScreen extends StatefulWidget {
  @override
  _MyTaskScreenState createState() => _MyTaskScreenState();
}

class _MyTaskScreenState extends State<MyTaskScreen> {
  Future<List<Task>>? _userTasks;

  @override
  void initState() {
    super.initState();
    _loadTasksBasedOnUser();
  }

Future<void> _loadTasksBasedOnUser() async {
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('user');

  if (userJson == null) {
    throw Exception('No user found in SharedPreferences');
  }

  final user = jsonDecode(userJson);
  print(user);
  final role = user['role'];
  print('User Role: $role');

  setState(() {
    _userTasks = role == 'provider'
        ? TaskService().getProviderTask()
        : TaskService().getUserTasks();
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _userTasks == null
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Task>>(
              future: _userTasks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No tasks found'));
                }
                print("Tasks from snapshot: ${snapshot.data!.length}");

                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final task = snapshot.data![index];
                      return MyTaskCard(task: task);
                    },
                  ),
                );
              },
            ),
    );
  }
}
