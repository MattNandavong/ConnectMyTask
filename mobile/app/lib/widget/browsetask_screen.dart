import 'package:app/model/task.dart';
import 'package:app/widget/task_items_card.dart';
import 'package:flutter/material.dart';
import 'package:app/utils/task_service.dart';
import 'package:app/widget/map_screen.dart';

class BrowseTask extends StatefulWidget {
  const BrowseTask({super.key});

  @override
  State<BrowseTask> createState() => _BrowseTaskState();
}

class _BrowseTaskState extends State<BrowseTask> {
  late Future<List<Task>> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = TaskService().getAllTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Task>>(
        future: _tasks,
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
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final task = snapshot.data![index];
                return TaskCard(context: context,task: task,);
              },
            ),
          );
        },
      ),
    );
  }
}
