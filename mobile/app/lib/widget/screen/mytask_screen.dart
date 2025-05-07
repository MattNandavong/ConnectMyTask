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
  String _selectedStatus = 'All';
  final List<String> _statusOptions = [
    'All',
    'Active',
    'In Progress',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    _loadTasksBasedOnUser();
  }

  Future<void> _loadTasksBasedOnUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) throw Exception('No user found in SharedPreferences');

    final user = jsonDecode(userJson);
    final role = user['role'];

    final allTasks = role == 'provider'
        ? await TaskService().getProviderTask()
        : await TaskService().getUserTasks();

    final filteredTasks = _selectedStatus == 'All'
        ? allTasks
        : allTasks.where(
            (t) => t.status.toLowerCase() == _selectedStatus.toLowerCase(),
          ).toList();

    setState(() {
      _userTasks = Future.value(filteredTasks);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _userTasks == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Task>>(
              future: _userTasks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Column(
                    children: [
                      _buildDropdown(),
                      const Expanded(
                        child: Center(child: Text('No tasks found')),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    _buildDropdown(),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12.0),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final task = snapshot.data![index];
                          return MyTaskCard(task: task);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: DropdownButtonFormField<String>(
        borderRadius: BorderRadius.circular(10),
        dropdownColor: Theme.of(context).colorScheme.background,
        value: _selectedStatus,
        items: _statusOptions.map((status) {
          return DropdownMenuItem<String>(
            value: status,
            child: Text(status, ),
            
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedStatus = value!;
          });
          _loadTasksBasedOnUser(); // call outside of setState
        },
        decoration: const InputDecoration(labelText: 'Task Status'),
        
      ),
    );
  }
}
